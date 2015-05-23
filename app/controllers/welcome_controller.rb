class WelcomeController < ApplicationController

  def index
  end

  def show
    @me = current_user.soundcloud_client.get("/me")
    @favorites = current_user.soundcloud_client.get("/me/favorites")
    @friends = current_user.soundcloud_client.get("/me/followings")
  end

end
