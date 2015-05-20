class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :soundcloud_user_id
      t.string :soundcloud_username
      t.integer :user_id
    end
  end
end
