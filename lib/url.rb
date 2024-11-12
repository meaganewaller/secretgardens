module Url
  def self.protocol
    ApplicationConfig["APP_PROTOCOL"]
  end

  def self.domain
    ApplicationConfig["APP_DOMAIN"]
  end

  def self.url(uri = nil)
    base_url = "#{protocol}#{domain}"
    return base_url unless uri

    Addressable::URI.parse(base_url).join(uri).normalize.to_s
  end
end
