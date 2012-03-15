require 'DataPoint'
require 'csv'

class PrintData

	#Printing csv to the files.
	def self.print_csv(datapoints,filename)
		CSV.open(filename, "wb",{:force_quotes => true}) do |csv|
			datapoints.each do |dp|
				temp = Array.new
				temp << dp.username
				temp << dp.original_tweet
				temp << dp.processed_tweet
				temp << dp.total_words
				temp << dp.least_idf_word1
				csv << temp 
			end
		end
	end

end