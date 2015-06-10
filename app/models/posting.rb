class Posting < ActiveRecord::Base
  belongs_to :post, class_name: "Track"
  belongs_to :user
end
