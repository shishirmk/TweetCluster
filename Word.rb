class Word
	attr_accessor :word, :idf, :proximity, :sentiment

	def to_s
		return "#{@word}"
	end

end