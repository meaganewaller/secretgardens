class Profile < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :location, :website_url, length: { maximum: 100 }
  validates :website_url, url: { allow_blank: true, no_local: true, schemas: %w[https http] }
  validates_with ProfileValidator

  ATTRIBUTE_NAME_REGEX = /(?<attribute_name>\w+)=?/
  CACHE_KEY = "profile/attributes".freeze
  STATIC_FIELDS = %w[summary location website_url].freeze

  def self.refresh_attributes!
    Rails.cache.delete(CACHE_KEY)
    attributes
  end

  def self.attributes
    Rails.cache.fetch(CACHE_KEY, expires_in: 24.hours) do
      ProfileField.pluck(:attribute_name)
    end
  end

  def self.static_fields
    STATIC_FIELDS
  end

  def clear!
    update(data: {})
  end

  def method_missing(method_name, ...)
    match = method_name.match(ATTRIBUTE_NAME_REGEX)
    super unless match

    field = ProfileField.find_by(attribute_name: match[:attribute_name])
    super unless field

    self.class.instance_eval do
      store_accessor :data, field.attribute_name.to_sym
    end
    public_send(method_name, ...)
  end

  def respond_to_missing?(method_name, include_private = false)
    match = method_name.match(ATTRIBUTE_NAME_REGEX)
    return true if match && match[:attribute_name].in?(self.class.attributes)

    super
  end
end
