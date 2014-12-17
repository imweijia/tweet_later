class User < ActiveRecord::Base
  # Remember to create a migration!
  has_many :tweets

  validates :nickname, uniqueness: true
  validates :access_token, uniqueness: true
  validates :access_token_secret, uniqueness: true

  def self.find_or_create(user_info)
    if User.exists?(nickname: user_info.info.nickname)
         user = User.find_by_nickname(user_info.info.nickname)
         user.update(access_token: user_info.extra.access_token.token, access_token_secret: user_info.extra.access_token.secret)
         return user
    else
      user = User.create(nickname: user_info.info.nickname, access_token: user_info.extra.access_token.token, access_token_secret: user_info.extra.access_token.secret)
      user.fetch_tweets!
      return user
    end
  end

  def fetch_tweets!
    tweets = client.user_timeline(self.nickname, count: 10)
    tweets.reverse.each do |t|
      Tweet.create(user_id: self.id, text: t.text)
    end
  end

  def post_tweet(tweet)
    client.update(tweet)
    self.fetch_tweets!
  end

   def post_tweet_later!(tweet_msg, time)
      # self.tweets.destroy_all
      puts "Time------------->#{time.to_i.minutes}"
      puts "tweet------------->#{tweet_msg}"
      tweet = self.tweets.create(text: tweet_msg)
      TweetWorker.perform_at(time.to_i.minutes, tweet.id)
   end

  def tweet(status)
    twt = self.tweets.create!(text: status)
    jid = TweetWorker.perform_async(twt.id)
  end

  private
  def client
    Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = self.access_token
    config.access_token_secret = self.access_token_secret
    end
  end
end
