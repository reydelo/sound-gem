class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @sc_user = current_user.soundcloud_client.get("/users/#{@user.soundcloud_user_id}")
  end

  def index
    @users = current_user.friends.all
  end

end
