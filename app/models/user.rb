class User < ActiveRecord::Base

  # Email Regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Make all email addresses lowercase to ensure consistency in db
  before_save { self.email = email.downcase }

  ##
  ## VALIDATIONS

  # Name exists and is no longer than 50 characters
  validates :name, presence: true, length: { maximum: 50 }

  # Email exists, 255 chars or less, is unique, valid, and case insensitive
  validates :email, presence: true, length: { maximum: 255 },
		   format: { with: VALID_EMAIL_REGEX },
		   uniqueness: { case_sensitive: false }

  # Password exists, 72 chars or less, matches password_confirmation, BCrypt password.
  # Ships with methods to set and authenticate agains BCrypt passwords.
  # API: http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html
  has_secure_password

  # Password is no less than 6 characters
  validates :password, length: { minimum: 6 }
end
