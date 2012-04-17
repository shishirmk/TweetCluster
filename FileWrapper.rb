class FileWrapper
  attr_accessor :filename
  
  def get_tweets()
    tweets = Array.new
    File.open(@filename).each_line do |s|
      temp = Tweet.new
      temp.username = ""
      temp.language = ""
      text = s.gsub(/\n|\r/,'')
      temp.original_tweet = text if !text.empty?
      temp.time = ""
      tweets << temp
    end
    return tweets
  end
  
  def get_multi_user_tweets()
    tweets_list = Array.new
    tweets = Array.new
      File.open(@filename).each_line do |s|
        if s.gsub(/\n|\r/,'').empty?
          tweets_list << tweets
          tweets = Array.new
        else
          temp = Tweet.new
          temp.username = ""
          temp.language = ""
          text = s.gsub(/\n|\r/,'')
          temp.original_tweet = text if !text.empty?
          temp.time = ""
          tweets << temp
        end
      end
    tweets_list << tweets 
    return tweets_list
  end  

end
