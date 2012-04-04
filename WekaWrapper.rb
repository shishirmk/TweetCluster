
class WekaWrapper
	attr_accessor :weka_path, :input_path, :output_path, :data_arff

	def points_to_arff(all_points)
		len = all_points.length
		puts len
		rel = Rarff::Relation.new('Test')
		instances = Array.new
		len.times do |i|
			temp = Array.new
			temp << i

			3.times do |j|
				if all_points[i].word_array[j].nil?
					temp << '?'
					next
				end
				temp << all_points[i].word_array[j].word
			end
			instances << temp
		end
		rel.instances = instances
		rel.attributes[0].name = 'Index'
		rel.attributes[0].type = 'NUMERIC'
		rel.attributes[1].name = 'Word1'
		#rel.attributes[1].type = 'NOMINAL'
		rel.attributes[2].name = 'Word2'
		#rel.attributes[2].type = 'NOMINAL'
		rel.attributes[3].name = 'Word3'
		#rel.attributes[3].type = 'NOMINAL'


		m = rel.to_arff
		local_filename = "Tests/test.arff"
		File.open(local_filename, 'w') {|f| f.write(m) }
		tem = %x{java -classpath "C:\\Program Files\\Weka-3-6\\weka.jar" weka.filters.unsupervised.attribute.StringToNominal -R first-last -i "Tests\\test.arff" -o "Tests\\test1.arff"}
		@data_arff = "Tests\\test1.arff"
	end

	def run_em
		output = %x{java -classpath "C:\\Program Files\\Weka-3-6\\weka.jar" weka.filters.unsupervised.attribute.AddCluster  -i "Tests\\test1.arff" -o "Tests\\out.arff" -I "First" -W "weka.clusterers.EM" }
		puts output
	end

	def get_clusters(all_points)
		File.open("Tests\\out.arff").each_line do |line|
				next if line.match(/^@|^\s/)
				line_parts = line.chomp.split(',')
				index = line_parts[0].to_i
				cluster_index = line_parts[-1].gsub(/^cluster/,'').to_i
				puts "cluster number #{cluster_index.to_s}"
				all_points[index].cluster = cluster_index
			end
		#all_points should now have cluster numbers.
	end

end