class Point
  attr_accessor :attr_hash, :tweet

  # Constructor that takes in a hash containing attributes and there properties as key and value respectively.
  def initialize(attr_hash = {}, tweet = "")
    @attr_hash = attr_hash
    @tweet = tweet
  end


  # Calculates the distance to Point p
  def dist_to(p)
    cost = 0
    first_array = @attr_hash.keys.clone
    second_array = p.attr_hash.keys.clone
    (0..first_array.length-1).each do |i|
      flag = 0
      (0..second_array.length-1).each do |j|
        if first_array[i] == second_array[j]
          flag = 1
          second_array.delete_at(j)
          break
        end
      end
      if flag == 0
        cost += 1
      end
    end
    return cost
  end

  # Return a String representation of the object
  def to_s
    return "#{@attr_hash.keys}"
  end
end