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

def kmeans(data, k, delta=1)
  clusters = []

  # Assign intial values for all clusters
  (1..k).each do |point|

    c = Cluster.new(data.sample)

    clusters.push c
  end


  # Loop
  while true
    # Assign points to clusters
    data.each do |point|
      min_dist = +INFINITY
      min_cluster = clusters.sample

      # Find the closest cluster
      clusters.each do |cluster|
        dist = point.dist_to(cluster.center)

        if dist < min_dist
          min_dist = dist
          min_cluster = cluster
        end
      end

      # Add to closest cluster
      min_cluster.points.push point
    end

    # Check deltas
    max_delta = -INFINITY

    clusters.each do |cluster|
      dist_moved = cluster.recenter!

      # Get largest delta
      if dist_moved > max_delta
        max_delta = dist_moved
      end
    end

    # Check exit condition
    if max_delta < delta
      return clusters
    end

    # Reset points for the next iteration
    clusters.each do |cluster|
      cluster.points = []
    end

  end  # end of while
  return clusters
end  # end of kmeans()