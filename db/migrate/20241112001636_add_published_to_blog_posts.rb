class AddPublishedToBlogPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :blog_posts, :published, :boolean, default: false
  end
end
