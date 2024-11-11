class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :location
      t.string :website_url
      t.jsonb :data, null: false, default: {}
      t.text :summary

      t.timestamps
    end
  end
end
