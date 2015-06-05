class UserCleanupWorker
  include Sidekiq::Worker

  def perform(user_id)
    sc_user = User.find_by(soundcloud_user_id: user_id)
    me = soundcloud_client.get("/me")
    # do lots of user cleanup stuff here

    # find/create the sc_user's favorite tracks
    limit = me.public_favorites_count
    tracks = sc_user.soundcloud_client.get("/me/favorites", :limit => limit)
    tracks.each do |track|
      track = Track.find_or_create_by(:soundcloud_track_id => track.id)
      sc_user.favorites.find_or_create_by(:track_id => track.id)
    end

    # find/create the sc_user's followings as friends
    limit = me.followings_count
    peeps = sc_user.soundcloud_client.get("/me/followings", :limit => limit)
    peeps.each do |peep|
      user = User.find_or_create_by(soundcloud_user_id: peep.id)
      user.update_attributes!({
        soundcloud_username: peep.username,
        avatar_url: peep.avatar_url
        })
        sc_user.friendships.find_or_create_by(:friend_id => user.id)

        # find/create the friend's favorite tracks
        limit = peep.public_favorites_count
        if limit != 0
          peep_tracks = sc_user.soundcloud_client.get("/users/#{peep.id}/favorites", :limit => limit)
          peep_tracks.each do |peep_track|
            track = Track.find_or_create_by(:soundcloud_track_id => peep_track.id)
            user.favorites.find_or_create_by(:track_id => track.id)
          end
        end
      end

    end

    private

    def soundcloud_client
      return @soundcloud_client if @soundcloud_client
      @soundcloud_client = User.soundcloud_client(:redirect_uri  => soundcloud_connected_url)
    end

  end
