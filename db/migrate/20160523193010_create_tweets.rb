class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.string :topic
      t.string :text
      t.string :user_name
      t.string :screen_name
      t.datetime :create_date
      t.string :link

      t.timestamps
    end
  end
end
