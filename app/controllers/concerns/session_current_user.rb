module SessionCurrentUser
  extend ActiveSupport::Concern

  def session_current_user_id
    return unless (key = session["warden.user.user.key"])

    key.first.first
  end
end
