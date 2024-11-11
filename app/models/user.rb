class User < ApplicationRecord
  include Signupable
  include Onboardable
  include Billable

  concerning :Profiles do
    included do
      has_one :profile, dependent: :delete

      attr_accessor :_skip_creating_profile

      after_create_commit unless: :_skip_creating_profile do
        Profile.find_or_create_by(user: self)
      rescue ActiveRecord::RecordNotUnique
        Rails.logger.warn("Profile already exists for user #{id}")
      end
    end
  end

  extend UniqueAcrossModels
  USERNAME_MAX_LENGTH = 30
  RECENTLY_ACTIVE_LIMIT = 10_000

  unique_across_models :username, length: { in: 2..USERNAME_MAX_LENGTH }

  scope :subscribed, -> { where.not(stripe_subscription_id: [nil, '']) }
  scope :recently_active, ->(active_limit = RECENTLY_ACTIVE_LIMIT) { order(updated_at: :desc).limit(active_limit) }
  before_validation :downcase_email
  # before_validation :set_username

  validate :password_matches_confirmation, if: :encrypted_password_changed?

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
    ["id", "admin", "created_at", "updated_at", "email", "username", "stripe_customer_id", "stripe_subscription_id", "paying_customer"]
  end

  def self.ransackable_associations(_auth_object)
    []
  end
  # :nocov:

  # def set_username
  #   self.username = username&.downcase.presence || generate_username
  # end
  #
  # def auth_provider_usernames
  #   attributes
  #     .with_indifferent_access
  #     .slice(*Authentication::Providers.username_fields)
  #     .values.compact || []
  # end
  #
  # def generate_username
  #   Users::UsernameGenerator.call(auth_provider_usernames)
  # end

  private

  def downcase_email
    self.email = email.downcase if email
  end

  def password_matches_confirmation
    return true if password == password_confirmation

    errors.add(:password, I18n.t("models.user.password_not_matched"))
  end

end
