# coding: utf-8

require 'redis'
require 'json'
require 'tf-idf'
require 'tweet'
require 'word'
require 'csv'

#Extending class array with a sum function.
class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end

#IDF functions
def create_tfidf_model(tweets)
  tfidf_model = TfIdf.new()
  for tweet in tweets
    tfidf_model.add_input_document(tweet.processed_tweet)
  end
  return tfidf_model
end

def get_idf(tfidf_model, tweet_text)
  words = tweet_text.split()
  idf_array = Array.new
  words.each do |word|
    idf_array << tfidf_model.idf(word)
  end
  return idf_array
end

#Proximity functions
def update_proximity(proximity_hash,tweet,i,max)
  words = tweet.split()
  words.each do |word|
    proximity_hash[word] = i
  end
end

def get_proximity(proximity_hash,tweet,i,max)
  proximity_array = Array.new
  words = tweet.split()
  words.each do |word|
    if proximity_hash[word].nil?
      proximity_array << max 
    else
      proximity_array << (i - proximity_hash[word])
    end
  end
  return proximity_array
end

#Make a hash with idf and proximity and group all words with same idf and proximity in the same array
def print_wordinfo(tweets)
  	rank_hash = Hash.new
  	tweets.each do |tweet|
  		tweet.word_array.each do |w|
	  		pair = [w.idf,w.proximity]
	  		if rank_hash[pair].nil?
	  			rank_hash[pair] = [w.word]
	  		else
	  			temp = rank_hash[pair]
	  			temp << w.word
	  			rank_hash[pair] = temp
	  		end
	  	end
  	end
  	rank_hash.keys.each do |pair|
  		puts "#{pair.to_s} => #{rank_hash[pair].to_s} "
  	end
end

#Get top 3 least idf words from a word_array
def top3(words)
	temp = words.sort{|a,b| a.idf <=> b.idf}
	return temp[0..2] if temp.length >= 3
end

#Printing the csv file for analysis
def print_csv(tweets,filename)
	CSV.open(filename, "wb",{:force_quotes => true}) do |csv|
		csv  << ["Username","Tweet","#Words","word1","word2","word3","idf1","idf2","idf3","prx1","prx2","prx3","Url Count","Hashtag Count","Chosen"]
		tweets.each do |tweet|
			words = top3(tweet.word_array)
			next if words.nil?
			temp = Array.new
			temp << tweet.username
			clean_tweet = tweet.original_tweet.gsub(/[[:punct:]]/,'').gsub(/\s+/,' ')
			temp << clean_tweet
			temp << clean_tweet.split().length #Number of words Includes all words like stop words etc
			temp << words[0].word
			temp << words[1].word
			temp << words[2].word
			temp << words[0].idf.round(4)
			temp << words[1].idf.round(4)
			temp << words[2].idf.round(4) 
			temp << words[0].proximity
			temp << words[1].proximity
			temp << words[2].proximity
			temp << Tweet.url_count(tweet.original_tweet)
			temp << Tweet.hashtag_count(tweet.original_tweet)
			if tweet.chosen.nil?
				temp << 0
			else
				temp << 1
			end
			csv << temp if !words.nil?
		end
  	end
end

#The main function >> All the action starts in here << 
def main_function()
	begin 
		redis = Redis.new(:host => "barreleye.redistogo.com", :port => 9283, :password => "c67e5bd9e2ce6eda9348ddc07d1859bf")
	rescue
		puts "Couldnt connect to redis"
	end
	all_keys =  redis.keys "*"
	["earthquake","harvest1","harvest-packers-falcons","lavsmohan","shishirmk","krishashok","SaketSrivastav","bobsaget","SrBachchan","irteen","warunsl","dens","gartenberg","bhogleharsha"].each do |uname|
		all_keys.delete(uname+"_tweets")
	end

	#Creating an array of tweet objects
	tweets = Array.new
	for key in all_keys
		key = "CNNLive_tweets"
		next if !all_keys.index("chosen_"+key)
		chosen_key = "chosen_"+key
		len = redis.llen chosen_key
		chosen_list = redis.lrange chosen_key,0, len-1

		len = redis.llen key
		tweet_list = redis.lrange key,0, len-1
		puts "#{key} => #{tweet_list.length}"
		tweet_list.each do |t|
			temp = Tweet.new
	    	temp.username = JSON.parse(t)['user']['screen_name']
	    	temp.language = JSON.parse(t)['user']['lang']
	    	temp.original_tweet = JSON.parse(t)['text']
	    	temp.time = JSON.parse(t)['created_at']
	    	temp.retweet = true if JSON.parse(t)['retweet_count'] != 0
	    	temp.reply = true if JSON.parse(t)['in_reply_to_status_id'] != "null"
	    	temp.chosen = true if chosen_list[0].index(temp.original_tweet)
	    	tweets << temp
	    end
	    break #To do run the code on just one user first
	end

	#Populating the word array of each tweet.
	tfidf_model = create_tfidf_model(tweets)
	proximity_hash = Hash.new
	idf_total = 0
	word_count = 0
	prox_total = 0
	tweet_index = 0
	max = tweets.length #Highest proximity number possible.
	for tweet in tweets
    	idf_array = get_idf(tfidf_model, tweet.processed_tweet)
    	proximity_array = get_proximity(proximity_hash,tweet.processed_tweet,tweet_index,max)
    	i = 0 # Number of words
    	tweet.processed_tweet.split().each do |w|
    		temp = Word.new
    		temp.word = w 
    		temp.idf = idf_array[i]
    		temp.proximity = proximity_array[i]
    		tweet.word_array << temp
    		i += 1
    	end
    	idf_total += idf_array.sum
    	prox_total += proximity_array.sum
    	word_count += idf_array.length
    	update_proximity(proximity_hash,tweet.processed_tweet,tweet_index,max)
    	tweet_index += 1 #To maintain the tweet number for proximity.
  	end
  	print_csv(tweets,ARGV[0])
end

main_function()