require 'stanford-core-nlp'

module NLP

	#Provide the parts of speech of tweet.
	def self.pos_sentence(tweet)

		#initial variables needed
		results_hash = Hash.new

		#
		pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos)
  		text = StanfordCoreNLP::Text.new(tweet.original_tweet.gsub(/[[:punct:]]/,''))
  		pipeline.annotate(text)

  		text.get(:sentences).each do |sentence|
  			sentence.get(:tokens).each do |token|
  				results_hash[token.get(:original_text).to_s] = token.get(:part_of_speech).to_s
  			end
  		end

  		processed_words = tweet.processed_tweet.split
  		keys_processed = Hash.new
  		results_hash.keys.each do |k|
  			p_word = Tweet.process(k)
  			keys_processed[p_word] = results_hash[k]
  		end

  		final_array = Array.new
  		processed_words.each do |word|
  			if !keys_processed[word].nil?
  				final_array << keys_processed[word] 
  			else
  				final_array << "UKN"
  			end
  		end
  				
		if final_array.length != tweet.processed_tweet.split.length #this is not very elegant
			raise "This function isnt doing well \n#{results_hash.keys.to_s} \n#{tweet.processed_tweet.split.to_s}"
		else
			#puts tweet.processed_tweet.split.to_s
			#puts final_array.to_s
			return final_array
		end

	end

end