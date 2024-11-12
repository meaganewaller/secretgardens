class User < ApplicationRecord
  include Signupable
  include Onboardable
  include Billable

  has_one :profile, dependent: :delete
  has_many :blog_posts, dependent: :destroy
  has_many :guild_memberships, dependent: :delete_all
  has_many :guilds, through: :guild_memberships

  extend UniqueAcrossModels
  USERNAME_MAX_LENGTH = 30
  RECENTLY_ACTIVE_LIMIT = 10_000

  unique_across_models :username, length: { in: 2..USERNAME_MAX_LENGTH }

  scope :subscribed, -> { where.not(stripe_subscription_id: [nil, '']) }
  scope :recently_active, ->(active_limit = RECENTLY_ACTIVE_LIMIT) { order(updated_at: :desc).limit(active_limit) }
  before_validation :downcase_email
  # before_validation :set_username

  validate :password_matches_confirmation, if: :encrypted_password_changed?, on: :update

  def tag_line
    profile.summary
  end

  def path
    "/#{username}"
  end

  def processed_website_url
    profile.website_url.to_s.strip if profile.website_url.present?
  end

  # :nocov:
  def self.ransackable_attributes(*)
    ["id", "admin", "created_at", "updated_at", "email", "username", "stripe_customer_id", "stripe_subscription_id", "paying_customer", "guilds"]
  end

  def self.ransackable_associations(_auth_object)
    []
  end

  def no_published_content?
    blog_posts.published.empty?
  end
  # :nocov:

  private

  def downcase_email
    self.email = email.downcase if email
  end

  def password_matches_confirmation
    return true if password == password_confirmation

    errors.add(:password, I18n.t("models.user.password_not_matched"))
  end

  def guild_member?(guild)
    guild_memberships.member.exists?(guild:)
  end
end
