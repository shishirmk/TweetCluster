# coding: utf-8
require 'redis'
require 'json'
require 'rubygems'

#User Defined
require 'WekaWrapper'
require 'TFIDFWrapper'
require 'RedisWrapper'
require 'FileWrapper'
require 'Proximity'
require 'PrintData'
require 'DataPoint'
require 'TwitterWrapper'
require 'Sentiment'
require 'Cluster'
require 'Point'
require 'Clusterer'
require 'Summary'
require 'NLP'
require 'rarff'

#Extending class array with a sum function.
module Enumerable

    def sum
      self.inject(0){|accum, i| accum + i }
    end

    def mean
      self.sum/self.length.to_f
    end

    def sample_variance(mean)
      return 1/0.0 if self.length <= 1
      m = mean || self.mean
      sum = self.inject(0){|accum, i| accum +(i-m)**2 }
      sum/(self.length - 1).to_f
    end

    def standard_deviation(mean)
      return Math.sqrt(self.sample_variance(mean))
    end

end

#The main function 
def main_function()

  #Assigning command line variables
  username = ARGV[1]
  source = ARGV[0]
  tweets = Array.new

  if source == "twitter"
    #Get user tweets from twitter
    twitter = TwitterWrapper.new
    tweets_json = twitter.user_tweets(username,100) 
    tweets = twitter.json_to_tweets(tweets_json)
  elsif source == "redis"
    redis = RedisWrapper.new
    tweet_list = redis.redis_client.lrange username+"_tweets", 0, -1
    tweet_list.each do |t|
      tweets.push(JSON.parse(t)['text'])
    end
    
    chosen_lists = redis.redis_client.lrange "chosen_"+username+"_tweets", 0 , -1
    user_tweets_file = File.new("Inputs/User_Tweets.txt","w+")
    for list in chosen_lists
      user_tweets_file << JSON.parse(list).join("\n")
      user_tweets_file << "\n\n"
    end
  else
   #Get tweets from a file in Inputs folder 
    twitter = FileWrapper.new()
    twitter.filename = "Inputs/"+username+".txt"
    tweets = twitter.get_tweets
  end
  
  #Filter retweets and reply. Just remove them from the list of tweets
  tweets = tweets.delete_if {|tweet| tweet.is_reply? or tweet.is_retweet?}
  puts "Tweets Returned Just fine" if !tweets.nil?

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
  pos_array = NLP.pos_sentence(tweet)
      i = 0 #Number of words
      tweet.processed_tweet.split().uniq.each do |w|
        temp = Word.new
        temp.word = w 
        temp.idf = idf_array[i]
        temp.proximity = proximity_array[i]
        temp.sentiment = sentiment_array[i]
        temp.pos = pos_array[i]
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

  #Clustering using LDA here.
  wk = WekaWrapper.new
  wk.points_to_arff(all_points)
  wk.run_em
  wk.get_clusters(all_points)
  final_clusters = Clusterer.map_to_clusters(all_points)

  #Output part
  output_filename = "Results/#{username}_em_results.txt"
  filewrapper = FileWrapper.new
  filewrapper.filename = "Inputs/User_Tweets.txt"
  tweets_list = filewrapper.get_multi_user_tweets()
  Clusterer.cluster_user_correlation("Results/#{username}_em_correlation.txt",final_clusters,tweets_list)
  Clusterer.print_to(output_filename,input_tweets,final_clusters)
  Clusterer.append_to(output_filename,"Max #words summary",Summary.simple_summary(final_clusters))
  Clusterer.append_to(output_filename,"Cluster Center Summary",Summary.center_summary(final_clusters))
  Clusterer.append_to(output_filename,"Highest Sentiment Summary",Summary.sentiment_summary(final_clusters))
  Clusterer.append_to(output_filename,"Random Generated Summary",Summary.random_summary(input_tweets))



  final_clusters = Array.new
  i = 2
  params_length = 3
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
    puts "#{Time.now} #{final_clusters.length}"
    puts "#{Point.get_counter}"
  end
  puts "Clustering done fine"

  output_filename = "Results/#{username}_kmeans_results.txt"
  Clusterer.cluster_user_correlation("Results/#{username}_kmeans_correlation.txt",final_clusters,tweets_list)
  Clusterer.print_to(output_filename,input_tweets,final_clusters)
  Clusterer.append_to(output_filename,"Max #words summary",Summary.simple_summary(final_clusters))
  Clusterer.append_to(output_filename,"Cluster Center Summary",Summary.center_summary(final_clusters))
  Clusterer.append_to(output_filename,"Highest Sentiment Summary",Summary.sentiment_summary(final_clusters))
  Clusterer.append_to(output_filename,"Random Generated Summary",Summary.random_summary(input_tweets))

  #puts "Cluster Centers"
  #final_clusters.each {|cluster| puts "#{cluster.center} #{cluster.sd(params_length)}" if cluster.points.length > 1}
  #Print tweets to a csv
  PrintData.print_csv(input_tweets,"Results/#{username}_data.csv",tweets_list)

end

main_function()
