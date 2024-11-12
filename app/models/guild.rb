class Guild < ApplicationRecord
  extend UniqueAcrossModels
  INTEGER_REGEXP = /\A\d+\z/

  before_validation :downcase_slug

  has_many :blog_posts, dependent: :nullify
  has_many :guild_memberships, dependent: :delete_all
  has_many :users, through: :guild_memberships

  # validates :email, length: { maximum: 64 }
  validates :name, presence: true
  validates :name, length: { maximum: 50 }
  validates :summary, length: { maximum: 250 }
  validates :tag_line, length: { maximum: 60 }
  validates :url, length: { maximum: 200 }, url: { allow_blank: true, no_local: true }

  unique_across_models :slug, length: { in: 2..30 }

  # :nocov:
  def self.ransackable_attributes(*)
    ["id", "name", "slug", "summary", "tag_line"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["blog_posts", "users"]
  end
  # :nocov:

  private

  def downcase_slug
    self.slug = slug&.downcase
  end
end
