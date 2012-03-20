require 'spellchecker'
require 'stemmer'
require 'time'
require 'StopWords'

class Tweet
  attr_accessor :username, :processed_tweet, :language, :word_array, :chosen
  attr_reader :time, :original_tweet
  def initialize(username = "",tweet = "" ,time = "",language = "en")
    @username = username
    @original_tweet = tweet
    @time = self.class.parse_time(time) if !time.empty?
    @language = language
    @word_array = []
    derived_attr(tweet) if !tweet.empty?
  end

  def time=(str)
    @time = self.class.parse_time(str) if !str.empty?
  end

  def derived_attr(tweet)
    @processed_tweet = self.class.process(tweet)
    @retweet = self.class.check_retweet(tweet)
    @reply = self.class.check_reply(tweet)
  end
  
  def original_tweet=(tweet)
    @original_tweet = tweet
    derived_attr(tweet) if !tweet.empty?
  end

  def retweet=(bool)
    @retweet = bool
  end

  def is_retweet?
    @retweet
  end

  def self.check_retweet(tweet)
    return true if tweet.match(/((\s+|^)(RT|rt))\s+.+/)
    return false
  end

  def reply=(bool)
    @reply = bool
  end

  def is_reply?
    @reply
  end

  def to_s
    return "#{@username}: #{@original_tweet}\nRetweet =#{@retweet} , Reply =#{@reply} "
  end

  def self.url_count(tweet)
    return tweet.scan(/(http|https):\/\//).length
  end

  def self.hashtag_count(tweet)
    return tweet.scan(/(^|\s)#(\w*[a-zA-Z_]+\w*)/).length
  end

  def self.check_spelling(tweet)
    temp = Spellchecker.check(tweet.gsub(/[[:punct:]]|[[:digit:]]/,''))
    correct_count = 0
    for i in temp
      if i[:correct] == true
        correct_count = correct_count + 1
      end
    end
      
    percentage = (Float(correct_count)/Float(temp.length))*100
    return percentage.round(2)
  end

  def self.check_reply(tweet)
    return true if tweet.match(/((((RT|rt)\s+)|^)(@[\w\W]+))\s+.+/)
    return false
  end

  def self.process(tweet)
    temp = Array.new
    stop_words = StopWords.new
    stop_words_hash = stop_words.get_hash()
    words = tweet.split()
    words.each do |word|
      processed_word = word.gsub(/[[:punct:]]/,'').strip().downcase()
      temp << processed_word.stem() if stop_words_hash[processed_word].nil?
    end
    return temp.join(' ')
  end

  def self.parse_time(str)
    timestamp_parts = str.split()
    time_parts = timestamp_parts[3].split(":")
    time_obj = Time.new(timestamp_parts[-1].to_i,timestamp_parts[1],timestamp_parts[2].to_i,time_parts[0].to_i,time_parts[1].to_i,time_parts[2].to_i,timestamp_parts[-2].insert(3,':'))
    return time_obj
  end

end