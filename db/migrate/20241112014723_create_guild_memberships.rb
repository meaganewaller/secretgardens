class CreateGuildMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :guild_memberships do |t|
      t.references :guild, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
