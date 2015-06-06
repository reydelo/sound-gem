class Track < ActiveRecord::Base
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites
  validates_uniqueness_of :soundcloud_track_id
end
