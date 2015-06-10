class CreatePostings < ActiveRecord::Migration
  def change
    create_table :postings do |t|
      t.integer :user_id
      t.integer :post_id
    end
  end
end
