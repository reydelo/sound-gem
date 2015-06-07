class UserCleanupWorker
  include Sidekiq::Worker

  def perform(sc_api)
    me = sc_api
    sc_user = User.find_by(soundcloud_user_id: me['id'])
    # do lots of user cleanup stuff here

    # find/create the sc_user's favorite tracks
    limit = me['public_favorites_count']
    user_tracks = sc_user.soundcloud_client.get("/me/favorites", :limit => limit)
    user_tracks.each do |user_track|
      track = Track.find_or_create_by(:soundcloud_track_id => user_track.id)
      track.update_attributes!({
        created_at: user_track.created_at
        })
      sc_user.favorites.find_or_create_by(:track_id => track.id)
    end

    # find/create the sc_user's followings as friends
    limit = me['followings_count']
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
            track.update_attributes!({
              created_at: peep_track.created_at
              })
            user.favorites.find_or_create_by(:track_id => track.id)
          end
        end
      end

    end


  end
