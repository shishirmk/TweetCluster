def kmeans(data, k, delta=1, iterations=10000)
  clusters = []

  # Assign intial values for all clusters
  (1..k).each do |point|
    c = Cluster.new(data.sample)
    clusters.push c
  end


  i = 0 
  # Loop
  while true
    # Assign points to clusters
    data.each do |point|
      min_dist = +INFINITY
      min_cluster = clusters[0]
      clusters.each do |cluster|
        dist = point.dist_to(cluster.center)h
        if dist < min_dist
          min_dist = dist
          min_cluster = cluster
        end
      end
      min_cluster.points.push point
    end
    i += 1

    # Check deltas
    max_delta = -INFINITY
    clusters.each do |cluster|
      dist_moved = cluster.recenter!
      if dist_moved > max_delta
        max_delta = dist_moved
      end
    end
    # Check exit condition
    if max_delta < delta or i > iterations
      return clusters
    end


    # Reset points for the next iteration
    clusters.each do |cluster|
      cluster.points = []
    end
  end  # end of while
  
  return clusters
end  # end of kmeans