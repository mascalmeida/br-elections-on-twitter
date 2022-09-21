# PACKAGES
## data manipulation
import pandas as pd
## show dataframe
from IPython.display import display
## Loading data from python to sql database
import sqlalchemy as sa
from sqlalchemy import create_engine
## working with mysql
import pymysql
## hiding MySQL credentials - ref: https://youtu.be/CJjSOzb0IYs
import mysqlcredentials


# LOAD NEW DATA IN MYSQL DATABASE

## Import datasets
df_users = pd.read_csv('datasets/profile_info_2022-09-20.csv')
df_count = pd.read_csv('datasets/profile_mentions_2022-09-20.csv')

## Conection to MySQL to upload data
user = mysqlcredentials.user
passw = mysqlcredentials.passw
host =  mysqlcredentials.host
database = mysqlcredentials.database
port = mysqlcredentials.port

engine = create_engine("mysql+pymysql://{user}:{pw}@{host}:{port}/{db}"
                       .format(user=user,
                               pw=passw,
                               host=host,
                               port=port,
                               db=database))

## Incremental logic - checking to avoid duplicates
last_update = pd.read_sql("SELECT * FROM vw_last_update", engine)
try:
    new_profile_info = df_users.loc[(pd.to_datetime(df_users['date']).dt.date > pd.to_datetime(last_update.loc[0, 'end_date']).date())]

    new_profile_mentions = df_count.loc[
        pd.to_datetime(df_count['end']).dt.tz_localize(None) > pd.to_datetime(last_update.loc[0, 'end']).tz_localize(None)
        ].reset_index(drop=True)
        
    display(new_profile_info, new_profile_mentions)
except:
    if len(last_update) == 0:
        print('database is empty')

## Loading new data
new_profile_info.to_sql(con=engine, name='profile_info', if_exists='append', index=False)
new_profile_mentions.to_sql(con=engine, name='profile_mentions', if_exists='append', index=False)