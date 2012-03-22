class Cluster
  attr_accessor :center, :points

  # Constructor with a starting centerpoint
  def initialize(center)
    @center = center
    @points = []
  end

  # Recenters the centroid point and removes all of the associated points
  def recenter!(k=3)
    old_center = @center
    # Reset center and return distance moved
    @center = Point.avg(@points)
    return old_center.dist_to(center)    
  end

  def to_s
    temp = "#{@center.word_array.sort{|a,b| a.idf <=> b.idf}}\nTweet: #{@center.original_tweet}\n"
    @points.each do |point|
      temp += point.to_s
      temp += "\n"
    end
    return temp
  end

  def size
    return @points.size
  end

end
