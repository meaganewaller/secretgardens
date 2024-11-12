class CreateGuilds < ActiveRecord::Migration[8.0]
  def change
    create_table :guilds do |t|
      t.string :name, null: false
      t.text :summary
      t.string :url
      t.datetime :last_blog_post_at, precision: nil, default: "2024-01-01 05:00:00"
      t.datetime :latest_blog_post_updated_at, precision: nil
      t.datetime :profile_updated_at, precision: nil, default: "2024-01-01 05:00:00"
      t.string :slug
      t.string :tag_line

      t.timestamps
    end

    add_index :guilds, :name, unique: true
    add_index :guilds, :slug, unique: true
  end
end
