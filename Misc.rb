# This file will hold all the miscellaneous functions of this Project
# This code can be referred back and used in the proper files. However none of these functions should be run as they are

#Redis connection
#retrieving keys
#creating the tweet object.
def get_tweets_from_redis
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
end

	#Printing the csv file for analysis
	def print_csv(tweets,filename)
		CSV.open(filename, "wb",{:force_quotes => true}) do |csv|
			csv  << ["Username","Tweet","#Words","word1","word2","word3","idf1","idf2","idf3","prx1","prx2","prx3","Url Count","Hashtag Count","Chosen"]
			tweets.each do |tweet|
				words = self.top3(tweet.word_array)
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