class User < ActiveRecord::Base

  # Email Regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessor :remember_token

  # Make all email addresses lowercase to ensure consistency in db
  before_save { self.email = email.downcase }


  ####
  #### VALIDATIONS

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
  validates :password, length: { minimum: 6 }, allow_blank: true


  ####
  #### SESSION HANDLING

  ## UPDATE TOKENS

  # Set remember_digest in db for validating a permanent cookie
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Delete remember_digest in db
  def forget
    update_attribute(:remember_digest, nil)
  end

  ## READ TOKENS

  # Return true if there is a match of permanent cookie
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  ## GENERATE TOKENS 

  # Returns a hash digest of a given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create( string, cost: cost )
  end

  # Returns a random url safe token
  def User.new_token
    SecureRandom.urlsafe_base64
  end
end
