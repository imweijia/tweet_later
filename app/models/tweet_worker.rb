# app/workers/tweet_worker.rb
class TweetWorker
  include Sidekiq::Worker

  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    user = tweet.user

    # set up Twitter OAuth client here
    # actually make API call
    # Note: this does not have access to controller/view helpers
    # You'll have to re-initialize everything inside here
    twitter_client = client(user.access_token, user.access_token_secret)
    twitter_client.update(tweet.text)
  end

  private
  def client(access_token, access_token_secret)
    Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = access_token
    config.access_token_secret = access_token_secret
    end
  end
end