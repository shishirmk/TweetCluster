require 'net/http'
require 'redis'
require 'uri'
require 'json'
require 'Tweet'

class TwitterWrapper

	attr_accessor :search_uri, :result_type, :rpp 

	def initialize(search_uri = "http://search.twitter.com:80/search.json", result_type = "recent", rpp = 10)
		#Refer https://dev.twitter.com/docs/api/1/get/search
		@search_uri = search_uri
		@rpp = rpp
		@result_type = result_type
	end

	def initialize()
	end

	def search_tweets(query)
		query = URI.escape(query, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))	
		uri = URI("#{@search_uri}?q=#{query}&rpp=#{@rpp}&result_type=#{@result_type}")
		response = Net::HTTP.get(uri)
		resposne_hash =  JSON.parse(response)
		results_array = resposne_hash["results"]
		return results_array
	end

	def eliminate_duplicates(tweets_array)
		temp_hash = Hash.new
		tweets_array.each do |tweet|
			temp_hash[tweet] = 1
		end
		return temp_hash.keys
	end

	def search_unique_tweets(query)
		results = self.search_tweets(query)
		return self.eliminate_duplicates(results)
	end

	def user_tweets(username,count=50,include_rts=false,exclude_replies=true)
		user_uri = "http://api.twitter.com/1/statuses/user_timeline.json"
		uri = URI("#{user_uri}?screen_name=#{username}&count=#{count}&include_rts=#{include_rts}&exclude_replies=#{exclude_replies}")
		response = Net::HTTP.get(uri)
		results_array  =  JSON.parse(response)
		return results_array
	end

	def json_to_tweets(json_array)
		tweets = Array.new
		json_array.each do |t|
			temp = Tweet.new
    	temp.username = t['user']['screen_name']
    	temp.language = t['user']['lang']
    	temp.original_tweet = t['text']
    	temp.time = t['created_at']
    	temp.retweet = true if t['retweet_count'] != 0
    	temp.reply = true if t['in_reply_to_status_id'] != "null"
    	#temp.chosen = true if chosen_list[0].index(temp.original_tweet) #Needs to done later
    	tweets << temp
	  end
	  return tweets
	end

end
