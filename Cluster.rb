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
    @center = Point.avg(@points,k)
    # puts "#{old_center.word_array}\n#{@center.word_array}"
    return old_center.dist_to(center,k)    
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

  def sd(k)
    return nil if @points.length == 0
    len = @points.length
    scores_array = Array.new
    i = 0; j = 0
    while i < len
      j = i + 1
      while j < len
        scores_array << @points[i].dist_to(@points[j],k)
        j = j + 1
      end
      i = i + 1
    end
    puts scores_array.to_s
    return scores_array.standard_deviation(0)
  end

end
