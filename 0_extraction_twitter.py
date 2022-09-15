# Packages
import json
from tweepy import OAuthHandler, Stream, StreamListener
from datetime import datetime

# Key access
cosumer_key = "xHG2qWclMuEJKDdIfxaVCBdau"
consumer_secret = "Kufd4X4qNT3AsbHweExiZWF6YYkJ6u0pTkCMquFFqGBf2Bzo1R"
access_token = "1429778781452095490-HRIHxVMeKneSgfYbGn1KWTUZtXPACz"
access_token_secret = "XAU1f2R8xd3vQuBQI5TGLo240TwoftUfBC24hIW0g7HkI"

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
