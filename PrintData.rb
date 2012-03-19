require 'DataPoint'
require 'csv'

class PrintData

	#Printing csv to the files.
	def self.print_csv(datapoints,filename)
		CSV.open(filename, "wb",{:force_quotes => true}) do |csv|
				temp = Array.new
				temp << "username"
				temp << "original_tweet"
				temp << "processed_tweet"
				temp << "total_words"
				temp << "least_idf_word1"
				temp << "least_idf_word2"
				temp << "least_idf_word3"
				temp << "sentiment1"
				temp << "sentiment2"
				temp << "sentiment3"
				csv << temp
			datapoints.each do |dp|
				temp = Array.new
				temp << dp.username
				temp << dp.original_tweet.gsub(/"*/,"")
				temp << dp.processed_tweet
				temp << dp.total_words
				temp << dp.least_idf_word1
				temp << dp.least_idf_word2
				temp << dp.least_idf_word3
				temp << dp.sentiment1
				temp << dp.sentiment2
				temp << dp.sentiment3
				csv << temp 
			end
		end
	end

end