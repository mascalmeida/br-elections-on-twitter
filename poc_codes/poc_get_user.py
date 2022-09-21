# Reference: https://www.geeksforgeeks.org/python-tweepy-getting-the-number-of-tweets-a-user-has-tweeted/
# Description: Getting the number of tweets a user has tweeted

# import the module
import tweepy as tw
## hiding API keys - ref: https://youtu.be/CJjSOzb0IYs
import apikeys
  
# assign the values accordingly
consumer_key = apikeys.key
consumer_secret = apikeys.secret
access_token = apikeys.token
access_token_secret = apikeys.token_secret
  
# authorization of consumer key and consumer secret
auth = tw.OAuthHandler(consumer_key, consumer_secret)
  
# set access to user's access key and access secret 
auth.set_access_token(access_token, access_token_secret)
  
# calling the api 
api = tw.API(auth)
  
# the screen name of the user
user_id = 2670726740 #@LulaOficial id
#user_id = 128372940 #@jairbolsonaro id
  
# fetching the user
user = api.get_user(user_id=user_id)
  
# fetching the statuses_count attribute
statuses_count = user.statuses_count 
  
print("The number of statuses the user has posted are : " + str(statuses_count))