class WelcomeController < ApplicationController
  def index
  end

  def show
    @favorites = current_user.soundcloud_client.get("/me/favorites")
    @friends = current_user.soundcloud_client.get("/me/followings")
    @friends.each do |x|
      @friend_favs = current_user.soundcloud_client.get("/users/#{x["id"]}/favorites")
    end
    @me = current_user.soundcloud_client.get("/me")
  end

  def update
    res = current_user.soundcloud_client.put("/me", :user => {:description => params[:description]})
    redirect_to :action => :show
  end
end
