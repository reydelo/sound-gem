class User < ActiveRecord::Base
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :favorites, dependent: :destroy
  has_many :tracks, through: :favorites
  has_many :postings, dependent: :destroy
  has_many :posts, through: :postings

  validates_uniqueness_of :soundcloud_user_id

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
    query = <<EOF
    SELECT tracks.*, COUNT(users.id) as num_favs FROM users

      INNER JOIN friendships
      ON friendships.friend_id = users.id

      INNER JOIN favorites
      ON users.id = favorites.user_id

      INNER JOIN tracks
      ON favorites.track_id = tracks.id

      WHERE friendships.user_id = :user_id

      GROUP BY tracks.id
      ORDER BY num_favs DESC
EOF
    @stream = Track.find_by_sql([query,
      user_id: self.id,
    ])
  end

  def recent
    query = <<EOF
    SELECT tracks.*, COUNT(users.id) as num_favs FROM users

      INNER JOIN friendships
      ON friendships.friend_id = users.id

      INNER JOIN favorites
      ON users.id = favorites.user_id

      INNER JOIN tracks
      ON favorites.track_id = tracks.id

      WHERE friendships.user_id = :user_id

      GROUP BY tracks.id
      ORDER BY created_at DESC
EOF
    @stream = Track.find_by_sql([query,
      user_id: self.id,
    ])
  end


end
