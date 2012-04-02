module Clusterer

  INFINITY = 1.0/0

  def self.cluster_init(data,k)
    clusters = []

    between = (data.length/k).round
    # Assign intial values for all cluster
    k.times do |i|
      c = Cluster.new(data[i*between])
      clusters.push c
    end

    return clusters
  end

  def self.outliers(data)
    outliers = Hash.new
    for pt1 in data
      flag = 0
      for pt2 in data

          next if pt1 == pt2
          for word1 in pt1.word_array
            for word2 in pt2.word_array
              if word1 == word2 
                #puts "#{word1.word} #{word2.word}"
                flag = 1
                break
              end
            end
            break
          end

          break if flag == 1
      end
      if flag == 0
        outliers[pt1] = 1
      end
    end
    #puts outliers.keys.length
  end


  def self.kmeans(data, k, params_length,delta=1, iterations=1000)

    clusters = self.cluster_init(data,k)
    
    i = 0 
    # Loop
    while true
      # Assign points to clusters
      data.each do |point|
        min_dist = point.dist_to(clusters[0].center,params_length)
        min_cluster = clusters[0]
        clusters.each do |cluster|
          dist = point.dist_to(cluster.center,params_length)
          if dist < min_dist
            min_dist = dist
            min_cluster = cluster
          end
        end
        min_cluster.points.push point
      end
      i += 1
      #Delete clusters with zero points assigned.
      clusters.delete_if {|cluster| cluster.points.length == 0}

      # Check deltas
      max_delta = -INFINITY
      clusters.each do |cluster|
        self.print_clusters(clusters) if cluster.points.length == 0
        dist_moved = cluster.recenter!(params_length)
        if dist_moved > max_delta
          max_delta = dist_moved
        end
      end
      # Check exit condition
      if max_delta < delta or i > iterations
        puts i
        return clusters
      end


      # Reset points for the next iteration
      clusters.each do |cluster|
        cluster.points = []
      end
    end  # end of while
    
    return clusters
  end  # end of kmeans

  def self.print_clusters(clusters)
    clusters.each do |cluster|
      puts cluster.to_s
      puts "\n"
    end
  end

  def self.print_to(filename,input_tweets,clusters)
    wfile = File.new(filename,"w+")
    input_tweets.each do |tweet|
      wfile << "#{tweet} \n"
    end
    wfile << "\n"
    clusters.each do |cluster|
      wfile << cluster.to_s
      wfile << "\n"
    end
    wfile.close
  end

  def self.append_to(filename,heading,input_tweets)
    wfile = File.new(filename,"a")
    wfile << "\n\n#{heading} \n"
    input_tweets.each do |tweet|
      wfile << "#{tweet} \n"
    end
    wfile.close
  end

end