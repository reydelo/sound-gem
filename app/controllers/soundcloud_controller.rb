class SoundcloudController < ApplicationController

  def connect
    redirect_to soundcloud_client.authorize_url(:display => "popup")
  end

  def connected
    if params[:error].nil?
      soundcloud_client.exchange_token(:code => params[:code])
      me = soundcloud_client.get("/me")
      login_as User.find_or_create_by({
        :soundcloud_user_id  => me.id,
        :soundcloud_username => me.username
      })
      current_user.update_attributes!({
        :soundcloud_access_token  => soundcloud_client.access_token,
        :soundcloud_refresh_token => soundcloud_client.refresh_token,
        :soundcloud_expires_at    => soundcloud_client.expires_at,
      })
      peeps = current_user.soundcloud_client.get("/me/followings")
      peeps.each do |peep|
        user = current_user.friends.find_or_create_by(
          :soundcloud_user_id => peep.id,
          :soundcloud_username => peep.username,
        )
        peep_tracks = current_user.soundcloud_client.get("/users/#{peep.id}/favorites")
        peep_tracks.each do |peep_track|
          user.tracks.find_or_create_by(
          :soundcloud_track_id => peep_track.id
          )
        end
      end
      tracks = current_user.soundcloud_client.get("/me/favorites")
      tracks.each do |track|
        current_user.tracks.find_or_create_by(
          :soundcloud_track_id => track.id
        )
      end
    end
    redirect_to you_path
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
