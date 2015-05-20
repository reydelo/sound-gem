class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :soundcloud_track_id
      t.integer :soundcloud_user_id
      t.string :soundcloud_title
      t.string :soundcloud_artist_username
      t.integer :soundcloud_artist_id
    end
  end
end
