class User < ActiveRecord::Base
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :favorites, dependent: :destroy
  has_many :tracks, through: :favorites

  def self.soundcloud_client(options={})
    options = {
      :client_id     => ENV['SOUNDCLOUD_CLIENT_ID'],
      :client_secret => ENV['SOUNDCLOUD_CLIENT_SECRET'],
    }.merge(options)
    Soundcloud.new(options)
  end

  def soundcloud_client(options={})
    options= {
      :expires_at    => soundcloud_expires_at,
      :access_token  => soundcloud_access_token,
      :refresh_token => soundcloud_refresh_token
    }.merge(options)
    client = self.class.soundcloud_client(options)
    # define a callback for successful token exchanges
    # this will make sure that new access_tokens are persisted once an existing
    # access_token expired and a new one was retrieved from the soundcloud api
    client.on_exchange_token do
      self.update_attributes!({
        :soundcloud_access_token  => client.access_token,
        :soundcloud_refresh_token => client.refresh_token,
        :soundcloud_expires_at    => client.expires_at,
      })
    end
    client
  end

  def popular
    @me = soundcloud_client.get("/me")
    current_user = User.find_by(soundcloud_user_id: @me.id)
    @stream = []
    current_user.friends.map do |friend|
      friend.tracks.each do |track|
        @stream << track
      end
    end.flatten.uniq
    @stream.select {|track| track.users.count > 4}.uniq
  end

end
