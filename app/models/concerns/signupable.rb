module Signupable
  attr_accessor :login

  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    # devise :database_authenticatable, :registerable, :recoverable, :rememberable
    # validates :email, uniqueness: { case_sensitive: false }, presence: true

    devise :database_authenticatable,
           :registerable,
           :recoverable,
           :rememberable,
           :validatable

    validates :email, uniqueness: { case_sensitive: false }, presence: true

    def self.find_for_database_authentication(warden_condition)
      conditions = warden_condition.dup
      login = conditions.delete(:login)
      where(conditions).where(
        ["lower(username) = :value OR lower(email) = :value",
         { value: login.strip.downcase }]
      ).first
    end
  end
end
