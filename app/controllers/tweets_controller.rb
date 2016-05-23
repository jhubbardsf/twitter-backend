class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show]

  def show
    @tweets
    render json: @tweets
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweets = Tweet.where(topic: params[:id])
    end
end
