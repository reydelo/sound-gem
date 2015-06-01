class WelcomeController < ApplicationController

  def index
    if current_user
      redirect_to you_path
    end
  end

  def show
    @me = current_user.soundcloud_client.get("/me")
    # @favorites = current_user.soundcloud_client.get("/me/favorites")
    # @friends = current_user.soundcloud_client.get("/me/followings")
  end

end
