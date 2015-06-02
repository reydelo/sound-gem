class WelcomeController < ApplicationController

  def index
  end

  def show
    @me = current_user.soundcloud_client.get("/me")
    @friend = current_user.soundcloud_client
    @stream = []
    current_user.friends.map do |friend|
      friend.tracks.each do |track|
        @stream << track
      end
    end.flatten.uniq
    peeps = current_user.friends
  end

end
