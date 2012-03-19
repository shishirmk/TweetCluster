# coding: utf-8
require 'redis'
require 'json'
require 'rubygems'

#User Defined
require 'TFIDFWrapper'
require 'Proximity'
require 'PrintData'
require 'DataPoint'
require 'TwitterWrapper'
require 'Sentiment'
require 'Cluster'
require 'Point'


INFINITY = 1.0/0

#Extending class array with a sum function.
class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end


#The main function 
def main_function()
	
	#Get user tweets from twitter
	twitter = TwitterWrapper.new
	tweets_json = twitter.user_tweets(ARGV[0])	
	tweets = twitter.json_to_tweets(tweets_json)

	#Populating the word array of each tweet
	tfidf = TFIDFWrapper.new(tweets)
	proximity = Proximity.new
	sentiment = Sentiment.new
	tweet_index = 0
	max = tweets.length #Highest proximity number possible.
	for tweet in tweets
    	idf_array = tfidf.idf_sentence(tweet.processed_tweet)
    	proximity_array = proximity.proximity_sentence(tweet.processed_tweet,tweet_index,max)
    	sentiment_array = sentiment.sentiment_sentence(tweet.processed_tweet)
    	i = 0 #Number of words
    	tweet.processed_tweet.split().uniq.each do |w|
    		temp = Word.new
    		temp.word = w 
    		temp.idf = idf_array[i]
    		temp.proximity = proximity_array[i]
    		temp.sentiment = sentiment_array[i]
    		tweet.word_array << temp
    		i += 1
    	end
  	#Updating stuff in the loop
  	proximity.update_proximity(tweet.processed_tweet,tweet_index)
  	tweet_index += 1 #To maintain the tweet number for proximity.
	end

	#Make datapoints out of tweets
	data_points = Array.new
	i = 0
	tweets.each do |tweet|
		t = DataPoint.new(i,tweet) 
		data_points << t if !t.empty? and !t.nil?
		i += 1
	end

	#Print tweets to a csv
  PrintData.print_csv(data_points,"Results/#{ARGV[0]}_data.csv")
end

main_function()