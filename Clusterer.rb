module Clusterer

  INFINITY = 1.0/0

  def self.cluster_init(data,k)
    clusters = []

    between = (data.length/k).round
    # Assign intial values for all cluster
    k.times do |i|
      c = Cluster.new()
      c.center = data[i*between]
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


  def self.kmeans(data, k, params_length,delta=1, iterations=100)

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

  def self.split_cluster(parent_cluster,final_clusters,branching,params_length)
    #parent_sd = parent_cluster.sd(params_length).round(2)
    all_points = parent_cluster.points
    clusters = self.kmeans(all_points,branching,params_length)
    clusters.length.times do |i|
      #child_sd = clusters[i].sd(params_length).round(2)
      #puts "child #{i}, #{clusters[i].center.word_array[0..2]}, #{child_sd} \nparent, #{parent_cluster.center.word_array[0..2]}, #{parent_sd}\n"
      if i != 0 or clusters[i].points.length <=2
        final_clusters << clusters[i]
      else
        self.split_cluster(clusters[i],final_clusters,branching,params_length)
      end
    end
    puts "#{Time.now} #{final_clusters.length}"
    # puts "#{Point.get_counter}"
  end

  def self.map_to_clusters(all_points)
    distinct_clusters = Hash.new
    c = 0
    for point in all_points
      distinct_clusters[point.cluster] = c
      c += 1
    end
    clusters_length = distinct_clusters.keys.length

    final_clusters = Array.new
    clusters_length.times do |i|
      temp = Cluster.new
      final_clusters << temp
    end

    c = 0 
    distinct_clusters.keys.each do |key|
      for point in all_points
        if point.cluster == key 
          final_clusters[c].points << point
        end
      end
      final_clusters[c].center = final_clusters[c].points.sample
      c += 1
    end

    return final_clusters
  end

end