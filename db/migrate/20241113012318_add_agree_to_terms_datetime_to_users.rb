class AddAgreeToTermsDatetimeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :agree_to_terms, :datetime, null: true
  end
end
