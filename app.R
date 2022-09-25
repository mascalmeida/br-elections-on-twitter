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
library(lubridate)
library(tippy)

## Lista os nomes dos candidatos com suas handles e cores
handles <- tibble(
  candidato = c("Lula", "Bolsonaro", "Ciro", "Simone"),
  screen_name = c("LulaOficial", "jairbolsonaro", "cirogomes", "simonetebetbr"),
  cor = c("#FF0A01", "#002B8F", "#FF01ED", "#D1C300")
)

## Define o svg das folhas
leaf_svg <- tags$svg(
  class = "leaf",
  xmlns="http://www.w3.org/2000/svg", 
  viewBox="0 0 576 512",
  tags$path(
    d="M546.2 9.7c-5.6-12.5-21.6-13-28.3-1.2C486.9 62.4 431.4 96 368 96h-80C182 96 96 182 96 288c0 7 .8 13.7 1.5 20.5C161.3 262.8 253.4 224 384 224c8.8 0 16 7.2 16 16s-7.2 16-16 16C132.6 256 26 410.1 2.4 468c-6.6 16.3 1.2 34.9 17.5 41.6 16.4 6.8 35-1.1 41.8-17.3 1.5-3.6 20.9-47.9 71.9-90.6 32.4 43.9 94 85.8 174.9 77.2C465.5 467.5 576 326.7 576 154.3c0-50.2-10.8-102.2-29.8-144.6z"
  )
)

## Define o svg do Twitter
tweet_svg <- tags$svg(
  class = "tweet",
  xmlns="http://www.w3.org/2000/svg", 
  viewBox="0 0 512 512",
  tags$path(
    d="M459.37 151.716c.325 4.548.325 9.097.325 13.645 0 138.72-105.583 298.558-298.558 298.558-59.452 0-114.68-17.219-161.137-47.106 8.447.974 16.568 1.299 25.34 1.299 49.055 0 94.213-16.568 130.274-44.832-46.132-.975-84.792-31.188-98.112-72.772 6.498.974 12.995 1.624 19.818 1.624 9.421 0 18.843-1.3 27.614-3.573-48.081-9.747-84.143-51.98-84.143-102.985v-1.299c13.969 7.797 30.214 12.67 47.431 13.319-28.264-18.843-46.781-51.005-46.781-87.391 0-19.492 5.197-37.36 14.294-52.954 51.655 63.675 129.3 105.258 216.365 109.807-1.624-7.797-2.599-15.918-2.599-24.04 0-57.828 46.782-104.934 104.934-104.934 30.213 0 57.502 12.67 76.67 33.137 23.715-4.548 46.456-13.32 66.599-25.34-7.798 24.366-24.366 44.833-46.132 57.827 21.117-2.273 41.584-8.122 60.426-16.243-14.292 20.791-32.161 39.308-52.628 54.253z"
  )
)

## Carrega os dados de acesso ao banco de dados
load_dot_env()

## Estabelece conexão com a base de dados
mysqlconnection <- DBI::dbConnect(
  RMySQL::MySQL(),
  dbname=Sys.getenv("database"),
  host=Sys.getenv("host"),
  port=3306,
  user=Sys.getenv("user"),
  password=Sys.getenv("passw")
)

## Efetua as queries e carrega os bancos
result <- dbSendQuery(mysqlconnection, "select * from profile_info")
profile <- fetch(result)
result <- dbSendQuery(mysqlconnection, "select * from profile_mentions")
mentions <- fetch(result)
result <- dbSendQuery(mysqlconnection, "select * from vw_last_update")
update <- fetch(result)

## Converter as datas de texto a data
mentions <- mentions %>% dplyr::mutate(end = ymd_hms(end),
                                       end_date = ymd(end_date))
profile <- profile %>% dplyr::mutate(date = ymd(date))
update <- update %>% dplyr::mutate(end = ymd_hms(end),
                                   end_date = ymd(end_date))

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
    
    ### Inclui autores
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
    
    ### Inclui suporte
    span("Support", class = "subtitles"),hr(class = "section"),
    div("Give a ⭐️ in our", a("GitHub", href="https://github.com/mascalmeida/br-elections-on-twitter", target = "_blank"), "project", class = "support"),
    div("React 👍 in our", a("LinkedIn", href="https://github.com/mascalmeida/br-elections-on-twitter", target = "_blank"),"post", class = "support"),
    div("Interact ❤️ in our", a("Twitter", href="https://github.com/mascalmeida/br-elections-on-twitter", target = "_blank"),"post", class = "support")
  )
  
  
  
)

# 3. Define a lógica do servidor
server <- function(input, output) {
  
  ## Gera a seção com as informações de update
  output$update <- renderUI({
    tagList(
      div(glue("🔄 Last update: {update$end}")),
      div(glue("🔜 Next update: {update$end_date+1} at 12PM"))
    )
  })
  
  ## Gera a seção com as principais estatísticas dos candidatos na rede
  output$stats <- renderUI({
    
    ### Obtém o total de mentions de cada candidato
    total_mentions <- mentions %>% 
      dplyr::summarise(across(.cols = ends_with("mentions"), .fns = sum)) %>% 
      tidyr::pivot_longer(cols = everything(),
                          names_to = c("screen_name",".value"),
                          names_sep = "_",
                          names_prefix = "@")
    
    ### Obtém o total de likes e followers de cada candidato
    total_info <- profile %>% 
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
    time <- mentions %>% 
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
    time <- mentions %>% 
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