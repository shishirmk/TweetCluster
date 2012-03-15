require 'Tweet'
require 'Word'

class DataPoint
	attr_accessor :position, :username, :original_tweet, :processed_tweet, :total_words, :least_idf_word1, :least_idf_word2, :least_idf_word3 , :sentiment1, :sentiment2, :sentiment3

	#Get top 3 least idf words from a word_array
	def top3(words)
		temp = words.sort{|a,b| a.idf <=> b.idf}
		return temp[0..2] if temp.length >= 3
	end

	def initialize(i,tweet)
		return if tweet.nil?
		words = self.top3(tweet.word_array)
		@position = i
		@username = tweet.username
		@original_tweet = tweet.original_tweet
		@processed_tweet = tweet.processed_tweet
		@total_words = tweet.word_array.length
		return if words.nil?
		@least_idf_word1 = words[0].word
		@least_idf_word2 = words[1].word
		@least_idf_word3 = words[2].word
		@sentiment1 = words[0].sentiment
		@sentiment2	= words[1].sentiment
		@sentiment3 = words[2].sentiment
	end

end