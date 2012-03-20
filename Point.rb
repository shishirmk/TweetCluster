class Point
  attr_accessor :original_tweet, :word_array

  # Constructor that takes in a hash containing attributes and there properties as key and value respectively.
  def initialize(tweet=nil)
    if !tweet.nil?
      @original_tweet = tweet.original_tweet
      @word_array = tweet.word_array.sort{|a,b| a.idf <=> b.idf}
    else 
      @original_tweet = nil
      @word_array = nil
    end
  end


  # Calculates the distance to Point p
  def dist_to(operand,k=3)
    matches = 0
    (0..k).each do |i|
      (0..k).each do |j|
        if !@word_array[i].nil? or !operand.word_array[j].nil?
          matches += 1 if @word_array[i] == operand.word_array[j]
        end
      end
    end

    dist = ((2*k) - matches)
    #puts dist if dist < 6 
    return dist 
  end

  #Class function for average of a given number of tweets
  def self.avg(input_array,k=3)
    len = input_array.length
    least_sum = 1000
    center_point = nil
    (0..len - 1).each do |i|
      sum = 0
      (0..len - 1).each do |j|
        sum += input_array[i].dist_to(input_array[j])
      end
      if sum < least_sum
        least_sum = sum
        center_point = input_array[i]
      end
    end
    return center_point
  end


  # Return a String representation of the object
  def to_s
    return "#{@original_tweet}"
  end

end