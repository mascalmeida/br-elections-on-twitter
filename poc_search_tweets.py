# Reference: https://medium.com/@robguilarr/making-queries-to-twitter-api-on-tweepy-66afeb7184a4
# Description: getting the last 50 tweets from a query

# Import packages
## tweepy - api to get data from twitter
import tweepy as tw
## hiding API keys - ref: https://youtu.be/CJjSOzb0IYs
import apikeys
## packages to data manipulation
import pandas as pd

# your Twitter API key and API secret
my_api_key = apikeys.key
my_api_secret = apikeys.secret
# authenticate
auth = tw.OAuthHandler(my_api_key, my_api_secret)
api = tw.API(auth, wait_on_rate_limit=True)

# Defining the query
search_query = '#eleições2022 -is:retweet'

# get tweets from the API
tweets = tw.Cursor(api.search_tweets,
              q=search_query,
              lang="pt").items(50)

# store the API responses in a list
tweets_copy = []
for tweet in tweets:
    tweets_copy.append(tweet)
    
# intialize the dataframe
tweets_df = pd.DataFrame()

# populate the dataframe
for tweet in tweets_copy:
    hashtags = []
    try:
        for hashtag in tweet.entities["hashtags"]:
            hashtags.append(hashtag["text"])
        text = api.get_status(id=tweet.id, tweet_mode='extended').full_text
    except:
        pass
    tweets_df = tweets_df.append(pd.DataFrame({'user_name': tweet.user.name, 
                                               'user_location': tweet.user.location,\
                                               'user_description': tweet.user.description,
                                               'user_verified': tweet.user.verified,
                                               'date': tweet.created_at,
                                               'text': text, 
                                               'hashtags': [hashtags if hashtags else None],
                                               'source': tweet.source}))
    tweets_df = tweets_df.reset_index(drop=True)

# show the dataframe
tweets_df.head()