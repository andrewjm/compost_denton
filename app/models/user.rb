class User < ActiveRecord::Base
  
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest

  # Email Regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
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

  # Activates an account
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

    def downcase_email 
      self.email = email.downcase 
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
