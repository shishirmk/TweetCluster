class RedisWrapper

	attr_accessor :redis_client

	def initialize(host,port,password)
		begin 
		@redis = Redis.new(:host => "barreleye.redistogo.com", :port => 9283, :password => "c67e5bd9e2ce6eda9348ddc07d1859bf")
		rescue
			return false
		end
	end

	def all_keys()
		all_keys =  self.redis.keys "*"
	end

	#Implement this.
	def write(username,tweets)
	end

end