require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  ##
  ## Designed to test the Remember feature of logging in specifically
  ## In the context of these tests, there has been no session created,
  ## only a remember_digest via the remember method

  # Setup and remember a test user 
  def setup
    @user = users(:andrew)
    remember(@user)
  end

  test "current_user should return correct user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user should return nil when remember digest is incorrect" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
