class AddCreatedAtToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :created_at, :datetime
  end
end
