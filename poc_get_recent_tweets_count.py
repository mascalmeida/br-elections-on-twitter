# Reference: https://dev.to/twitterdev/a-comprehensive-guide-for-using-the-twitter-api-v2-using-tweepy-in-python-15d9
# Description: getting the amount of tweets from a query

# Import packages
## tweepy - api to get data from twitter
import tweepy as tw
## hiding API keys - ref: https://youtu.be/CJjSOzb0IYs
import apikeys

## Authentication Tokens
my_bearer = apikeys.bearer

## creating client object
client = tw.Client(bearer_token=my_bearer)

# Replace with your own search query
query = '@LulaOficial -is:retweet'

counts = client.get_recent_tweets_count(query=query, granularity='day')

for count in counts.data:
    print(count)