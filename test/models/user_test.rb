require 'test_helper'

class UserTest < ActiveSupport::TestCase

  ##
  ## STRATEGY:

  ## 1. Setup a valid object.
  ## 2. Confirm it's valid.
  ## 3. Set each attribute to a non valid
  ##    value (based on the validations found in
  ##    app/models/user.rb) one by one.
  ## 4. Confirm the object is no longer valid.

  # Populate an @user object to test against
  def setup
    @user = User.new(		email: 			"user@example.com",
				password:	 	"foobar",
				password_confirmation: 	"foobar" )
  end

  # Confirm the @user object is valid
  test "user object is valid" do
    assert @user.valid?
  end

  ##
  ## NAME

  # Set name to blank and confirm invalid
  test "name should be present" do
    # @user.name = "   "
    # assert_not @user.valid?
  end

  # Set name too long and confirm invalid
  test "name should be 50 chars or less" do
    # @user.name = "a" * 51
    # assert_not @user.valid?
  end

  ##
  ## EMAIL

  # Set email to blank and confirm invalid
  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  # Set email too long and confirm invalid
  test "email should be 255 chars or less" do 
    @user.email = "a" * 300 + "@exmaple.com"
    assert_not @user.valid?
  end

  # Set email to valid formats and confirm valid
  test "valid email format should pass" do
    valid_addresses = %w[snoozer@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # Set email to invalid formats and confirm invalid
  test "invalid email format should fail" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  # Duplicate user and confirm unnique is invalid
  test "email should be unique" do
    user_copy = @user.dup
    user_copy.email = @user.email.upcase	# test case insensitivity
    @user.save					# @user needs to be in db
    assert_not user_copy.valid?
  end

  ##
  ## PASSWORD

  # Set password too short and confirm invalid
  test "password should be six characters or more" do
    @user.password = "abc"
    assert_not @user.valid?
  end

  # Set password too long and confirm invalid
  test "password should be 72 characters or less" do
    @user.password = "a" * 75
    assert_not @user.valid?
  end

  # Set password unequal to password_confirmation and confirm invalid
  test "password should match password_confirmation" do
    @user.password = "barfoo"
    assert_not @user.valid?
  end

  test 'authenticated? should return false for user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end
end
