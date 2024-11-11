class CrossModelSlug
  MODELS = {
    "User" => :username,
    "BlogPost" => :slug
  }.freeze

  class << self
    def exists?(value)
      return false if value.blank?

      value = value.downcase

      return true if value.include?("sitemap-")

      MODELS.detect do |class_name, attribute|
        class_name.constantize.exists?({ attribute => value })
      end
    end
  end
end
