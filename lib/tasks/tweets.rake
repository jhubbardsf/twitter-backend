namespace :tweets do
  desc 'Retrieve the 10 most recent tweets for the given topics.'
  task retrieve: :environment do
    topics = %w(nasa healthcare opensource)

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.consumer_key
      config.consumer_secret     = Rails.application.secrets.consumer_secret
      config.access_token        = Rails.application.secrets.access_token
      config.access_token_secret = Rails.application.secrets.access_token_secret
    end

    topics.each do |topic|
      tweets = client.search("\##{topic}").take(10)

      tweets.each do |tweet|
        new_tweet = Tweet.new

        new_tweet.topic = topic
        new_tweet.text = tweet.text
        new_tweet.user_name = tweet.user.name
        new_tweet.screen_name = tweet.user.screen_name
        new_tweet.create_date = tweet.created_at
        new_tweet.link = tweet.url.host + tweet.url.path

        new_tweet.save
      end
    end
  end

  desc 'Delete the oldest 10 tweets for each topic from the database.'
  task delete: :environment do
    topics = %w(nasa healthcare opensource)

    topics.each do |topic|
      tweets = Tweet.where(topic: topic).limit(10)
      Tweet.delete(tweets)
    end
  end
end
