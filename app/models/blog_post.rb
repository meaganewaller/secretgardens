class BlogPost < ApplicationRecord
  include ActionView::Helpers
  # all BIDI control marks (a part of them are expected to be removed during #normalize_title, but still)
  BIDI_CONTROL_CHARACTERS = /[\u061C\u200E\u200F\u202a-\u202e\u2066-\u2069]/

  # Filter out anything that isn't a word, space, punctuation mark,
  # recognized emoji, and other auxiliary marks.
  #
  # NOTE: try not to use hyphen (- U+002D) in comments inside regex,
  # otherwise it may break parser randomly.
  # Use underscore or Unicode hyphen (‐ U+2010) instead.
  # rubocop:disable Lint/DuplicateRegexpCharacterClassElement
  TITLE_CHARACTERS_ALLOWED = /[^
    [:word:]
    [:space:]
    [:punct:]
    \p{Sc}        # All currency symbols
    \u00a9        # Copyright symbol
    \u00ae        # Registered trademark symbol
    \u061c        # BIDI: Arabic letter mark
    \u180e        # Mongolian vowel separator
    \u200c        # Zero‐width non‐joiner, for complex scripts
    \u200d        # Zero-width joiner, for multipart emojis such as family
    \u200e-\u200f # BIDI: LTR and RTL mark (standalone)
    \u202c-\u202e # BIDI: POP, LTR, and RTL override
    \u2066-\u2069 # BIDI: LTR, RTL, FSI, and POP isolate
    \u20e3        # Combining enclosing keycap
    \u2122        # Trademark symbol
    \u2139        # Information symbol
    \u2194-\u2199 # Arrow symbols
    \u21a9-\u21aa # More arrows
    \u231a        # Watch emoji
    \u231b        # Hourglass emoji
    \u2328        # Keyboard emoji
    \u23cf        # Eject symbol
    \u23e9-\u23f3 # Various VCR‐actions emoji and clocks
    \u23f8-\u23fa # More VCR emoji
    \u24c2        # Blue circle with a white M in it
    \u25aa        # Black box
    \u25ab        # White box
    \u25b6        # VCR‐style play emoji
    \u25c0        # VCR‐style play backwards emoji
    \u25fb-\u25fe # More black and white squares
    \u2600-\u273f # Weather, zodiac, coffee, hazmat, cards, music, other misc emoji
    \u2744        # Snowflake emoji
    \u2747        # Sparkle emoji
    \u274c        # Cross mark
    \u274e        # Cross mark box
    \u2753-\u2755 # Big red and white ? emoji, big white ! emoji
    \u2757        # Big red ! emoji
    \u2763-\u2764 # Heart ! and heart emoji
    \u2795-\u2797 # Math operator emoji
    \u27a1        # Right arrow
    \u27b0        # One loop
    \u27bf        # Two loops
    \u2934        # Curved arrow pointing up to the right
    \u2935        # Curved arrow pointing down to the right
    \u2b00-\u2bff # More arrows, geometric shapes
    \u3030        # Squiggly line
    \u303d        # Either a line chart plummeting or the letter M, not sure
    \u3297        # Circled Ideograph Congratulation
    \u3299        # Circled Ideograph Secret
    \u{1f000}-\u{1ffff} # More common emoji
  ]+/m
  # rubocop:enable Lint/DuplicateRegexpCharacterClassElement

  has_one_attached :cover_image
  has_rich_text :body

  belongs_to :guild, optional: true
  belongs_to :user

  delegate :name, to: :user, prefix: true
  delegate :username, to: :user, prefix: true

  scope :published, -> { where(published: true) }
  # scope :drafts, -> { where(draft: true) }
  # scope :published, lambda {
  #   where(published: true)
  #     .where("published_at <= ?", time.current)
  # }
  scope :unpublished, -> { where(published: false) }
  scope :not_authored_by, ->(user_id) { where.not(user_id: user_id) }
  # scope :approved, -> { where(approved: true) }
  # scope :drafts, -> { where(draft: true) }
  # scope :featured, -> { where(featured: true) }

  validates :slug, presence: { if: :published? }, format: /\A[0-9a-z\-_]*\z/
  validates :slug, uniqueness: { scope: :user_id }
  validates :title, presence: true, length: { maximum: 128 }
  validates :description, presence: true, length: { maximum: 512 }
  validates :body, presence: true

  before_validation :create_slug
  before_validation :normalize_slug

  # before_validation :set_published_date
  before_validation :normalize_title
  before_validation :remove_prohibited_unicode_characters
  # before_validation :remove_invalid_published_at
  # before_save :set_cached_entities
  # before_save :set_all_dates

  # before_save :set_caches
  # before_save :detect_language
  # before_create :create_password
  # before_destroy :before_destroy_actions, prepend: true

  # after_save :bust_cache
  # after_save :generate_social_image

  # def scheduled?
  #   published_at? && published_at.future?
  # end

  def username
    return guild.slug if guild

    user.username
  end

  def class_name
    self.class.name
  end

  # def edited?
  #   edited_at.present?
  # end
  #
  # def readable_edit_date
  #   return unless edited?
  #
  #   if edited_at.year == Time.current.year
  #     I18n.l(edited_at, format: :short)
  #   else
  #     I18n.l(edited_at, format: :short_with_yy)
  #   end
  # end
  #
  # def readable_publish_date
  #   relevant_date = displayable_published_at
  #   return unless relevant_date
  #
  #   if relevant_date.year == Time.current.year
  #     I18n.l(relevant_date, format: :short)
  #   elsif relevant_date
  #     I18n.l(relevant_date, format: :short_with_yy)
  #   end
  # end
  #
  # def published_timestamp
  #   return "" unless published
  #   return "" unless crossposted_at || published_at
  #
  #   displayable_published_at.utc.iso8601
  # end
  #
  # def displayable_published_at
  #   crossposted_at.presence || published_at
  # end

  def to_param
    slug
  end

  # :nocov:
  def self.ransackable_attributes(_auth_object)
    ["created_at", "description", "draft", "id", "id_value", "slug", "title", "updated_at"]
  end
  # :nocov:

  private

  # def detect_language
  #   return unless title_changed? || body_changed?
  #
  #   self.language = Languages::Detection.call("#{title}, #{body_text}")
  # end

  def calculated_path
    if guild
      "/#{guild.slug}/#{slug}"
    else
      "/#{username}/#{slug}"
    end
  end

  def set_caches
    return unless user

    self.cached_user_name = user_name
    self.cached_user_username = user_username
    self.path = calculated_path.downcase
  end

  def normalize_title
    return unless title

    self.title =  title
                  .gsub(TITLE_CHARACTERS_ALLOWED, " ")
                  .gsub(/\s+/, " ")
                  .strip
  end

  # def before_destroy_actions
  #   bust_cache(destroying: true)
  #   blog_post_ids = user.blog_post_ids.dup
  #   if guild
  #     guild.touch(:last_blog_post_at)
  #     blog_post_ids.concat guild.blog_post_ids
  #   end
  #   # perform busting cache in chunks in case there're a lot of blog_posts
  #   # NOTE: `perform_bulk` takes an array of arrays as argument. Since the worker
  #   # takes an array of ids as argument, this becomes triple-nested.
  #   job_params = (blog_post_ids.uniq.sort - [id]).each_slice(10).to_a.map { |ids| [ids] }
  #   BlogPosts::BustMultipleCachesWorker.perform_bulk(job_params)
  # end

  # def parse_date(date)
  #   published_at || date || Time.current
  # end

  # def future_or_current_published_at
  #   # allow published_at in the future or within 15 minutes in the past
  #   return if !published || published_at.blank? || published_at > 15.minutes.ago
  #
  #   errors.add(:published_at, I18n.t("models.blog_post.future_or_current_published_at"))
  # end

  # def correct_published_at?
  #   return true unless changes["published_at"]
  #
  #   # for drafts (that were never published before) or scheduled blog_posts
  #   # => allow future or current dates, or no published_at
  #   if !published_at_was || published_at_was > Time.current
  #     # for blog_posts published_from_feed (exported from rss) we allow past published_at
  #     if (published_at && published_at < 15.minutes.ago) && !published_from_feed
  #       errors.add(:published_at, I18n.t("models.blog_post.future_or_current_published_at"))
  #     end
  #   else
  #     # for blog_posts that have been published already (published or unpublished drafts) => immutable published_at
  #     # allow changes within one minute in case of editing via frontmatter w/o specifying seconds
  #     has_nils = changes["published_at"].include?(nil) # changes from nil or to nil
  #     close_enough = !has_nils && (published_at_was - published_at).between?(-60, 60)
  #     errors.add(:published_at, I18n.t("models.blog_post.immutable_published_at")) if has_nils || !close_enough
  #   end
  # end

  def create_slug
    if slug.blank? && title.present? && !published
      self.slug = title_to_slug + "-temp-slug-#{rand(10_000_000)}"
    elsif should_generate_final_slug?
      self.slug = title_to_slug
    end
  end

  def should_generate_final_slug?
    (title && published && slug.blank?) ||
      (title && published && slug.include?("-temp-slug-"))
  end

  # def create_password
  #   return if password.present?
  #
  #   self.password = SecureRandom.hex(60)
  # end

  # def set_published_date
  #   self.published_at = Time.current if published && published_at.blank?
  # end

  def title_to_slug
    "#{Sterile.sluggerize(title)}-#{rand(100_000).to_s(26)}"
  end

  def touch_actor_latest_blog_post_updated_at(destroying: false)
    return unless destroying || saved_changes.keys.intersection(%w[title cached_tag_list]).present?

    user.touch(:latest_blog_post_updated_at)
    # guild&.touch(:latest_blog_post_updated_at)
  end

  def bust_cache(destroying: false)
    cache_bust = EdgeCache::Bust.new
    cache_bust.call(path)
    cache_bust.call("#{path}?i=i")
    cache_bust.call("#{path}?preview=#{password}")
    async_bust
    touch_actor_latest_blog_post_updated_at(destroying: destroying)
  end

  # def generate_social_image
  #   return if main_image.present?
  #
  #   change = saved_change_to_attribute?(:title) || saved_change_to_attribute?(:published_at)
  #   return unless (change || social_image.blank?) && published
  #
  #   Images::SocialImageWorker.perform_async(id, self.class.name)
  # end

  def async_bust
    BlogPosts::BustCacheWorker.perform_async(id)
  end

  def remove_prohibited_unicode_characters
    return unless title&.match?(BIDI_CONTROL_CHARACTERS)

    bidi_stripped = title.gsub(BIDI_CONTROL_CHARACTERS, "")
    self.title = bidi_stripped if bidi_stripped.blank? # title only contains BIDI characters = blank title
  end

  # Sometimes published_at is set to a date *way way too far in the future*, likely a parsing mistake. Let's nullify.
  # Do this instead of invlidating the record, because we want to allow the user to fix the date and publish as needed.
  # def remove_invalid_published_at
  #   return if published_at.blank?
  #
  #   self.published_at = nil if published_at > 5.years.from_now
  # end

  def normalize_slug
    return unless new_record? || slug_changed?

    intended_slug = slug.downcase.parameterize
    self.slug = intended_slug

    self.slug = "#{intended_slug}-#{SecureRandom.hex(3)}" while BlogPost.excluding(self).exists?(slug: self.slug)
  end
end
