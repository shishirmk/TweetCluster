class Cluster
  attr_accessor :center, :points

  # Constructor with a starting centerpoint
  def initialize(center)
    @center = center
    @points = []
  end

  def self.highest_repeated(input_array)
    max = 0
    max_word = nil
    temp = Hash.new
    input_array.each do |inp|
      if temp[inp].nil?
        temp[inp] = 1 
      else
        temp[inp] += 1
      end

      if temp[inp] > max
        max = temp[inp]
        max_word = inp
      end
    end
    return max_word
  end


  # Recenters the centroid point and removes all of the associated points
  def recenter!
    old_center = @center

    # Sum up all x/y coords
    temp = Array.new
    i = 0
    @points.each do |point|
      point.attr_hash.keys.each do |x|
        if temp[i].nil?
          temp[i] = [x]
        else
          temp[i] << x 
        end
        i = i + 1
      end
    end

    # Average out data
    result_hash = Hash.new
    temp.each do |arr|
      result_hash[self.class.highest_repeated(arr)] = "nominal"
    end

    # Reset center and return distance moved
    @center = Point.new(result_hash)
    return old_center.dist_to(center)    
  end
end
