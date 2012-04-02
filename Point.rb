class Point
  attr_accessor :original_tweet, :word_array
  @@counter = 0
  # Constructor that takes in a hash containing attributes and there properties as key and value respectively.

  def self.get_counter
    @@counter
  end
  
  def initialize(tweet=nil)
    if !tweet.nil?
      @original_tweet = tweet.original_tweet
      @word_array = tweet.word_array.sort{|a,b| a.idf <=> b.idf}
      @word_array.delete_if {|w| !w.pos.match(/NN.*|VB.*/) }
    else 
      @original_tweet = nil
      @word_array = nil
    end
    
  end


  # Calculates the distance to Point p
  def dist_to(operand,k=3)
    matches = 0
    @@counter += 1
    temp_hash = Hash.new
    @word_array[0..k-1].each {|word| temp_hash[word.word] = 1}
    operand.word_array[0..k-1].each {|word| matches += 1 if !temp_hash[word.word].nil? }
    #min_possible_count = [k, @word_array[0..k-1].length, operand.word_array[0..k-1].length].max

    dist = k - matches
    #puts "#{@word_array[0..k-1]}\n#{operand.word_array[0..k-1]}\n#{dist}"
    
    return dist 
  end

  # Overload operator ==
  def ==(op2)
    return true if @original_tweet == op2.original_tweet
    return false
  end

  #Class function for average of a given number of tweets
  def self.avg(input_array,k=3)
    len = input_array.length
    least_sum = nil
    center_point = nil
    (0..len - 1).each do |i|
      sum = 0
      (0..len - 1).each do |j|
        sum += input_array[i].dist_to(input_array[j],k)
      end
      if least_sum.nil? or sum < least_sum 
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