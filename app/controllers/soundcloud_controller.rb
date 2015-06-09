class SoundcloudController < ApplicationController

  def connect
    redirect_to soundcloud_client.authorize_url(display: "popup")
  end

  def connected
    if params[:error].nil?
      soundcloud_client.exchange_token(code: params[:code])
      # find/create the current user and pull in soundcloud information
      me = soundcloud_client.get("/me")
      login_as User.find_or_create_by(soundcloud_user_id: me.id)
      current_user.update_attributes!({
        soundcloud_username: me.username,
        avatar_url: me.avatar_url,
        soundcloud_access_token: soundcloud_client.access_token,
        soundcloud_refresh_token: soundcloud_client.refresh_token,
        soundcloud_expires_at: soundcloud_client.expires_at
        })
        UserCleanupWorker.perform_async(me)
      end
      redirect_to popular_path
    end

    def disconnect
      login_as nil
      redirect_to root_path
    end

    private

    def soundcloud_client
      return @soundcloud_client if @soundcloud_client
      @soundcloud_client = User.soundcloud_client(:redirect_uri  => soundcloud_connected_url)
    end

  end
