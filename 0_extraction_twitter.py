# Packages
import json
from tweepy import OAuthHandler, Stream, StreamListener
from datetime import datetime

# Key access
cosumer_key = "XXXXXXXXXXXXXXXXXXXXXX"
consumer_secret = "XXXXXXXXXXXXXXXXXXXXXX"
access_token = "XXXXXXXXXXXXXXXXXXXXXX"
access_token_secret = "XXXXXXXXXXXXXXXXXXXXXX"

# Define output to store twitter data
today_date = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
out = open(f"collected_tweets{today_date}.txt", "w")

# Connection class for Twitter
class MyListener(StreamListener):
    
    def on_data(self, data):
        #print(data)
        itemString = json.dumps(data)
        out.write(itemString + "\n")
        return True

    def on_error(self, status):
        print(status)

# Implement the MAIN function
if __name__ == "__main__":
    l = MyListener()
    auth = OAuthHandler(cosumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    stream = Stream(auth, l)
    stream.filter(track=["sustainability"])
