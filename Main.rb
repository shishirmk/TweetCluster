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
require 'Clusterer'
require 'Summary'

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
	tweets_json = twitter.user_tweets(ARGV[0],100)	
	tweets = twitter.json_to_tweets(tweets_json)
  #Filter retweets and reply. Just remove them from the list of tweets
  tweets = tweets.delete_if {|tweet| tweet.is_reply? or tweet.is_retweet?}
  puts "Tweets Returned Just fine"

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

  #Filter all tweets if they have word_array as nil
	all_points = Array.new
	i = 0
	tweets.each do |tweet|
		if tweet.word_array.length >= 3
			t = Point.new(tweet) 
			all_points << t 
			i += 1
		end
	end

  input_tweets = all_points.clone
  final_clusters = Array.new
  i = 2
  params_length = 1
  while !all_points.empty?
    clusters = Clusterer.kmeans(all_points,i,params_length)
    flag = 0
    all_points = Array.new
    for cluster in clusters
      if cluster.size <= 7 #This is the number limiting the final cluster size.
        final_clusters << cluster
        flag = 1
      else
        all_points += cluster.points
      end
    end
    if flag == 0
      i += 1
    else
      params_length += 1
    end
  end
  puts "Clustering done fine"

  chosen_summary = Summary.simple_summary(final_clusters)
  random_summary = Summary.random_summary(input_tweets) #cloned from all_points
  
  #Output part
  output_filename = "Results/#{ARGV[0]}_results.txt"
  Clusterer.print_to(output_filename,input_tweets,final_clusters)
  Clusterer.append_to(output_filename,"Computer Generated Summary",chosen_summary)
  Clusterer.append_to(output_filename,"Random Generated Summary",random_summary)
 	#Print tweets to a csv
 	#PrintData.print_csv(data_points,"Results/#{ARGV[0]}_data.csv")

end

main_function()