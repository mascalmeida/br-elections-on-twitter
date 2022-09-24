# IMPORT PACKAGES
try:  
    ## tweepy - api to get data from twitter
    import tweepy as tw
    ## hiding API keys - ref: https://youtu.be/CJjSOzb0IYs
    import apikeys
    ## data manipulation
    import pandas as pd
    ## date transformation
    from datetime import datetime, timedelta
    ## Loading data from python to sql database
    import sqlalchemy as sa
    from sqlalchemy import create_engine
    ## working with mysql
    import pymysql
    ## hiding MySQL credentials - ref: https://youtu.be/CJjSOzb0IYs
    import mysqlcredentials

except:
    print("Import packages error")

def run_etl(event, context):

    # CREATE CONNECTION WITH TWITTER API

    ## Authentication Tokens
    my_bearer = apikeys.bearer
    my_key = apikeys.key
    my_secret = apikeys.secret
    my_token = apikeys.token
    my_token_secret = apikeys.token_secret

    ## creating client object
    client = tw.Client(
        bearer_token=my_bearer, 
        consumer_key=my_key, 
        consumer_secret=my_secret, 
        access_token=my_token, 
        access_token_secret=my_token_secret
        )

    ## creating API object
    # authorization of consumer key and consumer secret
    auth = tw.OAuthHandler(
        consumer_key=my_key, 
        consumer_secret=my_secret
        )
    # set access to user's access key and access secret 
    auth.set_access_token(my_token, my_token_secret)
    # calling the api 
    api = tw.API(auth)
    print("SUCCESSUFUL - CONNECTION WITH TWITTER API")

    # TRANSFORM DATA - PROFILE QUANTITY MENTIONS

    # Replace with your own search query
    query_list = ['@LulaOficial', '@jairbolsonaro', '@cirogomes', '@simonetebetbr']
    query_filter = ' -is:retweet'

    ## all recent tweets mentions
    counts_recent = client.get_recent_tweets_count(query=query_list[0], granularity='hour')
    ## recent tweets mentions without retweets
    counts_recent_filtered = client.get_recent_tweets_count(query=query_list[0] + query_filter, granularity='hour')

    ## creating the dataframe and removing the first and the last range
    df_count = pd.DataFrame(counts_recent[0], columns=['start', 'end', 'tweet_count']).rename(columns={"tweet_count": query_list[0] + '_mentions'}).iloc[1:len(counts_recent[0])-1].reset_index(drop=True)
    ## convert date columns from string to datetime
    df_count['start'] = pd.to_datetime(df_count['start'], utc=True).map(lambda x: x.tz_convert('America/Bahia'))
    df_count['end'] = pd.to_datetime(df_count['end'], utc=True).map(lambda x: x.tz_convert('America/Bahia'))
    ## split datetime into date and time
    df_count['start_date'] = pd.to_datetime(df_count['start']).dt.date
    df_count['start_time'] = pd.to_datetime(df_count['start']).dt.time
    df_count['end_date'] = pd.to_datetime(df_count['end']).dt.date
    df_count['end_time'] = pd.to_datetime(df_count['end']).dt.time
    ## reorder the columns sequence
    df_count = df_count.loc[:, ['start', 'start_date', 'start_time', 'end', 'end_date', 'end_time', query_list[0] + '_mentions']]
    ## get tweet count without retweets
    df_temp = pd.DataFrame(counts_recent_filtered[0], columns=['tweet_count']).rename(columns={"tweet_count": query_list[0] + '_mentions_without_retweet'}).iloc[1:len(counts_recent[0])-1].reset_index(drop=True)
    df_count = pd.concat([df_count, df_temp], axis=1)
    ## check numeric columns type - fillna and convert to integer
    df_count[query_list[0] + '_mentions'] = df_count[query_list[0] + '_mentions'].fillna(0).astype(int)
    df_count[query_list[0] + '_mentions_without_retweet'] = df_count[query_list[0] + '_mentions_without_retweet'].fillna(0).astype(int)

    ## loop - get data about the top 4 candidates
    for i in range(1, len(query_list)):
        
        ## all recent tweets mentions
        counts_recent = client.get_recent_tweets_count(query=query_list[i], granularity='hour')
        ## recent tweets mentions without retweets
        counts_recent_filtered = client.get_recent_tweets_count(query=query_list[i] + query_filter, granularity='hour')

        ## get tweet count with retweets
        df_temp = pd.DataFrame(counts_recent[0], columns=['tweet_count']).rename(columns={"tweet_count": query_list[i] + '_mentions'}).iloc[1:len(counts_recent[0])-1].reset_index(drop=True)
        df_count = pd.concat([df_count, df_temp], axis=1)
        
        ## get tweet count without retweets
        df_temp = pd.DataFrame(counts_recent_filtered[0], columns=['tweet_count']).rename(columns={"tweet_count": query_list[i] + '_mentions_without_retweet'}).iloc[1:len(counts_recent[0])-1].reset_index(drop=True)
        df_count = pd.concat([df_count, df_temp], axis=1)
        
        ## check numeric columns type - fillna and convert to integer
        df_count[query_list[i] + '_mentions'] = df_count[query_list[i] + '_mentions'].fillna(0).astype(int)
        df_count[query_list[i] + '_mentions_without_retweet'] = df_count[query_list[i] + '_mentions_without_retweet'].fillna(0).astype(int)

    print("SUCCESSUFUL - TRANSFORM DATA 1 (MENTIONS)")

    # TRANSFORM DATA - PROFILE INFORMATION

    # Replace with your own users id 
    ## @LulaOficial id = 2670726740
    ## @jairbolsonaro id = 128372940 
    ## @cirogomes id = 33374761
    ## @simonetebetbr id = 2508415207
    user_id_list = [2670726740, 128372940, 33374761, 2508415207]

    # fetching the user
    user = api.get_user(user_id=user_id_list[0])
    # creating dataframe
    df_users = pd.DataFrame([datetime.today().strftime('%Y-%m-%d')], columns=['date'])
    # fetching the statuses_attributes
    df_users['screen_name'] = user.screen_name
    df_users['followers'] = user.followers_count
    df_users['following'] = user.friends_count
    df_users['posts'] = user.statuses_count
    df_users['lists'] = user.listed_count
    df_users['likes'] = user.favourites_count

    ## loop - get data about the top 4 candidates
    for i in range(1, len(user_id_list)):
        # fetching the user
        user = api.get_user(user_id=user_id_list[i])
        # fetching the statuses_attributes
        df_temp =  pd.DataFrame([datetime.today().strftime('%Y-%m-%d')], columns=['date'])
        # fetching the statuses_attributes
        df_temp['screen_name'] = user.screen_name
        df_temp['followers'] = user.followers_count
        df_temp['following'] = user.friends_count
        df_temp['posts'] = user.statuses_count
        df_temp['lists'] = user.listed_count
        df_temp['likes'] = user.favourites_count

        # adding the info about the new user
        df_users = pd.concat([df_users, df_temp])

    print("SUCCESSUFUL - TRANSFORM DATA 2 (INFO)")

    # LOAD NEW DATA IN AWS MYSQL DATABASE

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

    except:
        if len(last_update) == 0:
            print('database is empty')

    ## Loading new data
    new_profile_info.to_sql(con=engine, name='profile_info', if_exists='append', index=False)
    new_profile_mentions.to_sql(con=engine, name='profile_mentions', if_exists='append', index=False)
    print("SUCCESSUFUL - LOADING")

    return(print(">>>>> ETL is done! <<<<<"))