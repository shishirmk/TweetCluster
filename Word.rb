class Word
	attr_accessor :word, :idf, :proximity, :sentiment

	def initialize
	end

	def to_s
		return "#{@word}"
	end

	def ==input
		if input.class != Word
			return true if @word == input
			return false
		else
			return true if @word == input.word
			return false
		end
	end

end