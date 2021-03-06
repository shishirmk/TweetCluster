require 'net/http'
require 'redis'
require 'uri'
require 'json'
require 'Tweet'

class TwitterWrapper

	SEARCH_URI = "http://search.twitter.com:80/search.json"
	USER_URI = "http://api.twitter.com/1/statuses/user_timeline.json"
	attr_accessor :result_type, :rpp 

	def initialize( result_type = "recent", rpp = 10)
		#Refer https://dev.twitter.com/docs/api/1/get/search
		@search_uri = SEARCH_URI
		@rpp = rpp
		@result_type = result_type
	end

	def search_tweets(query)
		query = URI.escape(query, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))	
		uri = URI("#{@search_uri}?q=#{query}&rpp=#{@rpp}&result_type=#{@result_type}")
		begin
			response = Net::HTTP.get(uri)
		rescue
			puts "Twitter is sending data"
		end
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
		user_uri = USER_URI
		uri = URI("#{user_uri}?screen_name=#{username}&count=#{count}&include_rts=#{include_rts}&exclude_replies=#{exclude_replies}\n")
		begin
			response = Net::HTTP.get(uri)
			results_array  =  JSON.parse(response)
		rescue
			puts "Twitter is not sending data"
		end
		return results_array
	end

	def json_to_tweets(json_array)
		tweets = Array.new
		json_array.each do |t|
			temp = Tweet.new
    	temp.username = t['user']['screen_name']
    	temp.language = t['user']['lang']
    	temp.original_tweet = t['text'].gsub(/\n|\r/,'')
    	temp.time = t['created_at']
    	#temp.chosen = true if chosen_list[0].index(temp.original_tweet) #Needs to done later
    	tweets << temp
	  end
	  return tweets
	end

end
