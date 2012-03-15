class Sentiment

  attr_accessor :sentihash

  def initialize
    @sentihash = load_senti_file ('Sentiment/sentiwords.txt')
    @sentihash.merge!(load_senti_file ('Sentiment/sentislang.txt'))
  end

  #####################################################################
  # Function analyzes the sentiment of a tweet. Very basic. This just
  # imports a list of words with sentiment scores from file and uses
  # these to perform the analysis.
  #
  # tweet: string -- string to analyze the sentiment of
  # return: int -- 0 negative, 1 means neutral, and 2 means positive
  #####################################################################
  def total_sentiment(text)
    # tokenize the text
    tokens = text.split
    sentiment_total = 0.0
    for token in tokens do
      sentiment_value = self.sentihash[token]
      if sentiment_value
        sentiment_total += sentiment_value
      end
    end
    
    # threshold for classification
    threshold = 0.0
    # if less then the negative threshold classify negative
    if sentiment_total < (-1 * threshold)
      return 0
    # if greater then the positive threshold classify positive
    elsif sentiment_total > threshold
      return 2
    # otherwise classify as neutral
    else
      return 1
    end
  end


  def sentiment_sentence(text)
    tokens = text.split
    sentiment_total = 0.0
    sentiment_array = Array.new
    for token in tokens do
      sentiment_value = self.sentihash[token]
      if sentiment_value
        sentiment_array << sentiment_value
      else
        sentiment_array << 0.0
      end
    end
    return sentiment_array
  end


  #####################################################################
  # load the specified sentiment file into a hash
  #
  # filename:string -- name of file to load
  # sentihash:hash -- hash to load data into
  # return:hash -- hash with data loaded
  #####################################################################
  def load_senti_file (filename)
    sentihash = {}
    # load the word file
    begin
      file = File.new(filename)
      while (line = file.gets)
        parsedline = line.chomp.split("\t")
        sentiscore = parsedline[0]
        text = parsedline[1]
        sentihash[text] = sentiscore.to_f
      end
      file.close
    rescue 
      puts "sentislang.txt or sentiswords.txt are missing"
    end

    return sentihash
  end 

end