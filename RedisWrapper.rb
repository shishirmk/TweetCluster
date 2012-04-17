class RedisWrapper

	attr_accessor :redis_client

	def initialize()
		begin 
  		@redis_client = Redis.new(:host => "barreleye.redistogo.com", :port => 9283, :password => "c67e5bd9e2ce6eda9348ddc07d1859bf")
		rescue
			return false
		end
	end

end
