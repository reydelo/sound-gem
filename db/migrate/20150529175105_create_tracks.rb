class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :soundcloud_track_id
    end
  end
end
