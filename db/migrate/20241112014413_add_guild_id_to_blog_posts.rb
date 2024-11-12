class AddGuildIdToBlogPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :blog_posts, :guild, foreign_key: true
  end
end
