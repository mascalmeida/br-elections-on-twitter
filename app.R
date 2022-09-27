# 1. Carregamento das bibliotecas e bancos de dados
library(shiny)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggiraph)
library(ggpath)
library(glue)
library(purrr)
library(scales)
library(dotenv)
library(DBI)
library(RMySQL)
library(pool)
library(lubridate)
library(tippy)

## Lista os nomes dos candidatos com suas handles e cores
handles <- tibble(
  candidato = c("Lula", "Bolsonaro", "Ciro", "Simone"),
  screen_name = c("LulaOficial", "jairbolsonaro", "cirogomes", "simonetebetbr"),
  cor = c("#FF0A01", "#002B8F", "#FF01ED", "#D1C300")
)

## Carrega os dados de acesso ao banco de dados
load_dot_env()

## Estabelece conexão com a base de dados
pool <- pool::dbPool(
  RMySQL::MySQL(),
  dbname=Sys.getenv("database"),
  host=Sys.getenv("host"),
  port=3306,
  user=Sys.getenv("user"),
  password=Sys.getenv("passw")
)

# 2. Define o arranjo da UI
ui <- fluidPage(
  
  ## Conecta o app ao CSS
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  
  ## Conecta o app à fonte do Google Fonts
  tags$head(
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel="preconnect", href="https://fonts.gstatic.com"),
    tags$link(href="https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,400;0,700;1,400&display=swap", rel="stylesheet")
  ),
  
  ## Cria um container em torno do conteúdo
  div(
    id = "mega_container",
    
    ### Define título do app
    div("Brazilian Election on Twitter", id = "title"),
    
    ### Define seção de update
    uiOutput("update"),
    
    ### Define seção de desempenho
    span("Candidates numbers", class = "subtitles"),hr(class = "section"),
    uiOutput("stats"),
    
    ### Define seção de menções
    span("Mentions", class = "subtitles"),
    span(
      class = "subtitles",
      tippy(
        icon("circle-info"),
        placement = "right",
        allowHTML = TRUE,
        arrow = TRUE,
        tooltip = "The number of Tweets that mentioned<br>the candidate profile, including retweets"
      )
    ),
    hr(class = "section"),
    ggiraphOutput("timementions", height = "400px"),
    
    ### Define seção de menções
    span("Mentions without retweets", class = "subtitles"),hr(class = "section"),
    ggiraphOutput("timementions_wort", height = "400px"),
    
    ### Define seção de autores
    span("Authors", class = "subtitles"),hr(class = "section"),
    img(src = "images/lucas.png", class = "foto"),
    div(
      class = "credenciais",
      strong("Lucas Mascarenhas"),
      div(icon("github"), a("@mascalmeida", href = "https://github.com/mascalmeida", target = "_blank")),
      div(icon("linkedin"), a("lucas-mascarenhas", href = "https://www.linkedin.com/in/lucas-mascarenhas/", target = "_blank")),
      div("lucasmascalmeida@gmail.com")
    ),
    div(style="clear:both;margin-bottom:20px;"),
    
    img(src = "images/icaro.png", class = "foto"),
    div(
      class = "credenciais",
      strong("Ícaro Bernardes"),
      div(icon("github"), a("@IcaroBernardes", href = "https://github.com/IcaroBernardes", target = "_blank")),
      div(icon("linkedin"), a("icarobsc", href = "https://www.linkedin.com/in/icarobsc/", target = "_blank")),
      div(icon("twitter"), a("@IcaroBSC", href = "https://twitter.com/icarobsc", target = "_blank")),
      div("asaicaro@gmail.com")
    ),
    div(style="clear:both;"),
    
    ### Define seção de suporte
    span("Support", class = "subtitles"),hr(class = "section"),
    div("Give a ⭐️ in our", a("GitHub", href="https://github.com/mascalmeida/br-elections-on-twitter", target = "_blank"), "project", class = "support"),
    div("React 👍 in our", a("LinkedIn", href="https://www.linkedin.com/posts/lucas-mascarenhas_python-docker-mysql-activity-6980180488736935937-aXbK", target = "_blank"),"post", class = "support"),
    div("Interact ❤️ in our", a("Twitter", href="https://twitter.com/IcaroBSC/status/1574415139666890759", target = "_blank"),"post", class = "support")
  )
  
)

# 3. Define a lógica do servidor
server <- function(input, output) {
  
  ## Obtém os dados de mentions e adequa datas
  mentions <- reactive({
    
    query <- "select * from profile_mentions"
    db <- dbGetQuery(pool, query)
    db %>% dplyr::mutate(end = ymd_hms(end),
                         end_date = ymd(end_date))
    
  })
  
  ## Obtém os dados de profile info e adequa datas
  profile <- reactive({
    
    query <- "select * from profile_info"
    db <- dbGetQuery(pool, query)
    db %>% dplyr::mutate(date = ymd(date))
    
  })
  
  ## Obtém os dados de update e adequa datas
  update <- reactive({
    
    query <- "select * from vw_last_update"
    db <- dbGetQuery(pool, query)
    db %>% dplyr::mutate(end = ymd_hms(end),
                         end_date = ymd(end_date))
    
  })
  
  ## Gera a seção com as informações de update
  output$update <- renderUI({
    
    uplast <- update()$end
    upnext <- update()$end_date + 1
    
    tagList(
      div(glue("🔄 Last update: {uplast}")),
      div(glue("🔜 Next update: {upnext} at midnight"))
    )
    
  })
  
  ## Gera a seção com as principais estatísticas dos candidatos na rede
  output$stats <- renderUI({
    
    ### Obtém o total de mentions de cada candidato
    total_mentions <- mentions() %>% 
      dplyr::summarise(across(.cols = ends_with("mentions"), .fns = sum)) %>% 
      tidyr::pivot_longer(cols = everything(),
                          names_to = c("screen_name",".value"),
                          names_sep = "_",
                          names_prefix = "@")
    
    ### Obtém o total de likes e followers de cada candidato
    total_info <- profile() %>% 
      dplyr::slice_max(order_by = date, n = 1) %>% 
      dplyr::select(screen_name, followers, likes)
    
    ### Une os dados e inclui os nomes dos candidatos
    stats <- total_mentions %>% 
      dplyr::full_join(total_info) %>% 
      dplyr::full_join(handles) %>% 
      dplyr::mutate(id = 1:n())
    
    ### Gera a estrutura html dos "cards"
    stats %>%
      purrr::pmap(function(screen_name, mentions, followers, likes, candidato, cor, id) {
        
        div(
          class = "cards", id = glue("cards_{id}"),
          
          img(src = glue("images/{screen_name}.png"),
              style = glue("border:{cor} solid 5px;border-radius:40px;")),
          
          div(
            class = "stats_info",
            div(a(href = glue("https://twitter.com/{screen_name}"),
                  target = "_blank",
                  screen_name))
          ),
          
          div(
            class = "stats_followers",
            div(label_number(scale_cut = cut_si(""), accuracy = 0.1, decimal.mark = ",")(followers), class = "stats_values"),
            div("FOLLOWERS", class = "stats_titles")
          ),
          
          div(
            class = "stats_mentions",
            div(label_number(scale_cut = cut_si(""), accuracy = 0.1, decimal.mark = ",")(mentions), class = "stats_values"),
            div("MENTIONS", class = "stats_titles")
          )
        )
        
      })
    
  })
  
  ## Gera o gráfico com a série temporal de mentions
  output$timementions <- renderggiraph({
    
    ### Mantém apenas as variáveis de interesse e rearranja os dados
    time <- mentions() %>% 
      dplyr::select(data = end_date, ends_with("mentions")) %>% 
      tidyr::pivot_longer(cols = ends_with("mentions"),
                          names_to = c("screen_name",".value"),
                          names_sep = "_",
                          names_prefix = "@")
    
    ### Agrega os dados a nível diário
    time <- time %>%
      dplyr::group_by(data, screen_name) %>% 
      dplyr::summarise(mentions = sum(mentions)) %>% 
      dplyr::ungroup()
    
    ### Inclui os nomes e cores dos candidatos
    time <- time %>% dplyr::left_join(handles)
    
    ### Gera a tooltip a exibir
    time <- time %>% 
      dplyr::mutate(tooltip = glue("<div style='background-color:{cor};padding:12px;border-radius:15px;'>
                                   <strong>Candidate: <strong><span>{candidato}</span><br>
                                   <strong>Mentions: <strong><span>{mentions}</span><br>
                                   <strong>Date: <strong><span>{data}</span>
                                   </div>"))
    
    ### Gera o gráfico
    plot <- time %>% 
      ggplot(aes(x = data, y = mentions)) +
      geom_line_interactive(aes(data_id = candidato, color = I(cor)), size = 3) +
      geom_point_interactive(aes(data_id = candidato, tooltip = tooltip,
                                 color = I(cor)), size = 3, fill = "white",
                             shape = 21, stroke = 1) +
      scale_y_continuous(n.breaks = 11, labels = label_number()) +
      scale_x_date(date_breaks = "3 days") +
      theme_minimal() +
      theme(
        plot.background = element_rect(fill = "#1D9BF0", color = NA),
        panel.grid.minor = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 20, color = "white"),
        axis.text.x = element_text(angle = 40, hjust = 1)
      )
    
    ### Converte a um objeto ggiraph
    girafe(
      ggobj = plot, width_svg = 8, height_svg = 6,
      options = list(
        opts_tooltip(css = "background:none;color:white;"),
        opts_toolbar(pngname = "mentions"),
        opts_hover_inv(css = "opacity:0.3;"),
        opts_hover(css = "stroke-width:2;")
      ))
    
  })
  
  ## Gera o gráfico com a série temporal de mentions sem rt
  output$timementions_wort <- renderggiraph({
    
    ### Mantém apenas as variáveis de interesse e rearranja os dados
    time <- mentions() %>% 
      dplyr::select(data = end_date, ends_with("mentions_without_retweet")) %>% 
      tidyr::pivot_longer(cols = ends_with("mentions_without_retweet"),
                          names_to = c("screen_name",".value"),
                          names_sep = "_",
                          names_prefix = "@")
    
    ### Agrega os dados a nível diário
    time <- time %>%
      dplyr::group_by(data, screen_name) %>% 
      dplyr::summarise(mentions = sum(mentions)) %>% 
      dplyr::ungroup()
    
    ### Inclui os nomes e cores dos candidatos
    time <- time %>% dplyr::left_join(handles)
    
    ### Gera a tooltip a exibir
    time <- time %>% 
      dplyr::mutate(tooltip = glue("<div style='background-color:{cor};padding:12px;border-radius:15px;'>
                                   <strong>Candidate: <strong><span>{candidato}</span><br>
                                   <strong>Mentions: <strong><span>{mentions}</span><br>
                                   <strong>Date: <strong><span>{data}</span>
                                   </div>"))
    
    ### Gera o gráfico
    plot <- time %>% 
      ggplot(aes(x = data, y = mentions)) +
      geom_line_interactive(aes(data_id = candidato, color = I(cor)), size = 3) +
      geom_point_interactive(aes(data_id = candidato, tooltip = tooltip,
                                 color = I(cor)), size = 3, fill = "white",
                             shape = 21, stroke = 1) +
      scale_y_continuous(n.breaks = 11, labels = label_number()) +
      scale_x_date(date_breaks = "3 days") +
      theme_minimal() +
      theme(
        plot.background = element_rect(fill = "#1D9BF0", color = NA),
        panel.grid.minor = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 20, color = "white"),
        axis.text.x = element_text(angle = 40, hjust = 1)
      )
    
    ### Converte a um objeto ggiraph
    girafe(
      ggobj = plot, width_svg = 8, height_svg = 6,
      options = list(
        opts_tooltip(css = "background:none;color:white;"),
        opts_toolbar(pngname = "mentions"),
        opts_hover_inv(css = "opacity:0.3;"),
        opts_hover(css = "stroke-width:2;")
      ))
    
  })
  
}

shinyApp(ui, server)