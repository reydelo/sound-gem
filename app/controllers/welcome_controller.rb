class WelcomeController < ApplicationController

  def index
  end

  def show
    @stream = []
    current_user.friends.map do |friend|
      friend.tracks.each do |track|
        @stream << track
      end
    end.flatten.uniq
    @popular = @stream.select {|track| track.users.count > 4}.uniq
  end

end
