module Summary

	#Just pull the longest string
	def self.simple_summary(clusters)
		chosen_points = Array.new
		for cluster in clusters
			if cluster.points.length <= 2
				next
			end
			max = 0
			choice = nil
			for point in cluster.points
				if point.original_tweet.split.length > max 
					max = point.original_tweet.split.length
					choice = point
				end
			end
			chosen_points << choice
		end
		return chosen_points
	end

	def self.center_summary(clusters)
		chosen_points = Array.new
		for cluster in clusters
			next if cluster.points.length <= 2
			chosen_points << cluster.center.original_tweet
		end
		return chosen_points
	end

	def self.random_summary(input_points)
		fraction = 0.15
		chosen_points = Array.new
		summary_count = ((input_points.length)*0.15).round
		summary_count.times do 
			chosen_points << input_points.delete(input_points.sample)
		end
		return chosen_points
	end

	def self.sentiment_summary(clusters)
		chosen_points = Array.new
		for cluster in clusters
			next if cluster.points.length <= 2
			max = 0
			choice = nil
			for point in cluster.points
				sum = 0
				for word in point.word_array
					sum += word.sentiment.abs
				end
				if max < sum
					max = sum
					choice = point
				end
			end
			chosen_points << choice
		end
		return chosen_points
	end

end