# <p align="center" style="margin-top: 0px;"><img align="center" alt="urna" height="45" width="45" src="https://user-images.githubusercontent.com/48625700/192151877-e07c0c2a-f2cf-49f7-ad1c-9392bbde3b74.png"> Brazilian Election on Twitter <img align="center" alt="twitter" height="40" width="50" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/twitter/twitter-original.svg">

This project is a data-driven solution that uses Twitter data to analyse the brazilian presidency candidates profiles performance.

:pushpin: Link to go to Shiny App :point_right: [click here!](https://icarob.shinyapps.io/electionsbr/) :point_left:


  
Note: it is updated everyday at 12PM.

## Achitecture

![architecture_v0](https://user-images.githubusercontent.com/48625700/192274947-17c9a7e9-124f-408d-a754-7645e7dabd50.png)

### AWS Resources

| Resource | Function    | Description    |
| :---:   | :---: | :---: |
| [EventBridge](https://aws.amazon.com/eventbridge/) | Trigger the ETL   | Build event-driven applications at scale across AWS, existing systems, or SaaS apps   |
| [ECR](https://aws.amazon.com/ecr/) | Store the container with the ETL   | Easily store, share, and deploy your container software anywhere   |
| [Lambda](https://aws.amazon.com/lambda/) | Run the ECR with the ETL   | Run code without thinking about servers or clusters   |
| [RDS](https://aws.amazon.com/rds/) | Operate MySQL Database   | Set up, operate, and scale a relational database in the cloud with just a few clicks   |

### ETL

- **Extraction**: Tweepy is a python package that make easier the access to Twitter API. The functions that have been used here are: 
  1. [get_recent_tweets_count](https://developer.twitter.com/en/docs/twitter-api/tweets/counts/api-reference/get-tweets-counts-recent). This function gets the number of Tweets that mentioned the query words.
  2. [get_user](https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/get-users-show). This function gets information about the user, i.e. followers, posts, screen name and etc.

- **Transformation**: The main package used to transform and manipulate data was Pandas, it was used mainly to transform data scraped from Twitter API into pandas data frame format.

- **Loading**: The SQLAlchemy was used to create the connection ([engine](https://docs.sqlalchemy.org/en/14/core/engines.html)) between the python code and the MySQL database, it is possible to combine this connection with [Pandas load function](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.to_sql.html).

### MySQL Database

- **Profile Mentions Table**: Store the number of total mentions, mentions without retweets, and the respective date and time. It is an hourly table.

<p align="center">
<img width="600px"  src="https://user-images.githubusercontent.com/48625700/192282051-6a544d8a-58c7-4979-b527-e6fde679f258.png" />
</p>

- **Profile Info Table**: Store some important info about the users and the respective date. It is a daily table.

<p align="center">
<img width="450px"  src="https://user-images.githubusercontent.com/48625700/192283402-9746ac51-0127-4a34-9ac2-3855eee21395.png" />
</p>

- **Last Updated View**: Store the date and time of the last time that the ETL ran.

<p align="center">
<img width="350px"  src="https://user-images.githubusercontent.com/48625700/192284151-0ea77cff-6b3d-4f9a-86f0-de3616e7872b.png" />
</p>

### Shiny App

- **Connecting the app to the MySQL Database**: Remote databases are an excellent solution to keep a Shiny app updated. The `pool` package helps establish and manage remote storage connections. Of course, some sensitive information is needed to build these bridges between the app and storage. That's when the `dotenv` package comes to aid: it allows the developer to hide their credentials in a .env file, upload it to the host service, and easily access them.

- **Leveraging the power of `purrr`**: When building an app UI, one can use HTML tags inside the `R` code. Just like some `ggplot2` layers, these tags are stored in lists. This means that `purrr` can be used to build such structures, especially if they are repetitive.

- **Interactive dataviz**: `ggiraph` is a `ggplot2`-friendly package to build interactive plots. It helps to create plots that do not overwhelm users with data. Hover events and tooltips aid the user to focus on particular aspects of a plot.

## References
- Tweepy functions: https://dev.to/twitterdev/a-comprehensive-guide-for-using-the-twitter-api-v2-using-tweepy-in-python-15d9
- Tweepy hands-on: https://youtu.be/q8q3OFFfY6c
- Docker + Lambda: https://youtu.be/2VtuNOEw8S4

------------------------------------------------------------
### Support

Give a ⭐️ if you like this project!

React 👍 in our [Linkedin post!](https://www.linkedin.com/posts/lucas-mascarenhas_python-docker-mysql-activity-6980180488736935937-aXbK/)

Interact ❤️ in our [Twitter post!](https://twitter.com/IcaroBSC/status/1574415139666890759)
