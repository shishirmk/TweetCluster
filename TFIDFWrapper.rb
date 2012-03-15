require 'tf-idf'
require 'Tweet'

class TFIDFWrapper

  attr_accessor :tfidf_model

  #IDF functions
  #Creates the tfidf model for a given set of tweet objects
  def initialize(tweets)
    @tfidf_model = TfIdf.new
    for tweet in tweets
      @tfidf_model.add_input_document(tweet.processed_tweet)
    end
  end

  #Takes in a sentence and returns as array with idf of each word in the sentence. 
  def idf_sentence(tweet_text)
    words = tweet_text.split()
    idf_array = Array.new
    words.each do |word|
      idf_array << @tfidf_model.idf(word)
    end
    return idf_array
  end

end