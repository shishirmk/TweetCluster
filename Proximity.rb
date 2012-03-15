class Proximity
  attr_accessor :proximity_hash
  
  def initialize
    @proximity_hash = Hash.new
  end

  #Updates the proximity hash with the words of the given tweet
  def update_proximity(tweet,i)
    words = tweet.split()
    words.each do |word|
      self.proximity_hash[word] = i
    end
  end

  #Calculates the proximity based on present tweet words and previous occurance of that word.
  #Max is the tolal number of tweets in the array used for proximity calculation
  #Returns an array with proximity values of each word. 
  def proximity_sentence(tweet,i,max)
    proximity_array = Array.new
    words = tweet.split()
    words.each do |word|
      if self.proximity_hash[word].nil?
        proximity_array << max 
      else
        proximity_array << (i - self.proximity_hash[word])
      end
    end
    return proximity_array
  end
end