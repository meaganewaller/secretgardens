class RegistrationsController < Devise::RegistrationsController
  before_action :protect_from_spam, only: [:create]

  layout 'auth'
end
