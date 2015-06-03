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
      limit = me.followings_count
      peeps = current_user.soundcloud_client.get("/me/followings", :limit => limit)
      peeps.each do |peep|
        user = User.find_or_create_by(
        :soundcloud_user_id => peep.id,
        :soundcloud_username => peep.username
        )
        current_user.friendships.find_or_create_by(:friend_id => user.id)
        peep_tracks = current_user.soundcloud_client.get("/users/#{peep.id}/favorites", :limit => 100)
        peep_tracks.each do |peep_track|
          track = Track.find_or_create_by(:soundcloud_track_id => peep_track.id)
          user.favorites.find_or_create_by(:track_id => track.id)
        end
      end
      limit = me.public_favorites_count
      tracks = current_user.soundcloud_client.get("/me/favorites", :limit => limit)
      tracks.each do |track|
        track = Track.find_or_create_by(:soundcloud_track_id => track.id)
        current_user.favorites.find_or_create_by(:track_id => track.id)
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
