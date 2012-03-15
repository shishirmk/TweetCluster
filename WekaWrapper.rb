require "java"
require "weka"

include_class "weka.clusterers.SimpleKMeans"
include_class "weka.core.Instances"
include_class "weka.core.Instance"
include_class "weka.core.Attribute"
include_class "weka.core.FastVector"

module WekaWrapper


	def WekaWrapper.make_vector(nominal_array)
	  atts = FastVector.new(nominal_array.length)
	  nominal_array.each {|arg| atts.addElement arg}
	  return atts
	end

	def WekaWrapper.uniq_values(datapoints,name)
		temp_hash = Hash.new
		datapoints.each do |dp|
			temp_hash[dp.send(name)] = true
		end
		return temp_hash.keys
	end


	def WekaWrapper.datapoints_to_clusters(datapoints)
		ts = uniq_values(datapoints,"least_idf_word1")
		ms = make_vector(ts)
		word1 = Attribute.new("word1", ms )
		word2 = Attribute.new("word2", make_vector(uniq_values(datapoints,"least_idf_word2")))
		word3 = Attribute.new("word3", make_vector(uniq_values(datapoints,"least_idf_word3")))

		dataset = Instances.new("Twitter dataset", make_vector([word1,word2,word3]),datapoints.length)

		datapoints.each do |dp|
			instance = Instance.new 3
			instance.setValue(word1,dp.least_idf_word1)
			instance.setValue(word2,dp.least_idf_word2)
			instance.setValue(word3,dp.least_idf_word3)
			instance.setDataset dataset
			dataset.add instance
		end

		kmeans = SimpleKMeans.new
		kmeans.buildClusterer dataset

		# Display the cluster for each instance
		dataset.numInstances.times do |i|
		  cluster = "UNKNOWN"
		  begin
		    cluster = kmeans.clusterInstance(dataset.instance(i))
		  rescue java.lang.Exception
		  end
		  puts "#{dataset.instance(i)}, #{cluster}"
		end
	end

end
