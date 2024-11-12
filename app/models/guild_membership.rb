class GuildMembership < ApplicationRecord
  belongs_to :guild
  belongs_to :user

  validates :user_id, uniqueness: { scope: :guild_id }

  # after_create :update_user_guild_info_updated_at
  # after_destroy :update_user_guild_info_updated_at
end
