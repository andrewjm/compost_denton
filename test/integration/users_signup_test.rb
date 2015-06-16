require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # clear out mailer deliveries from last test run
  def setup
    ActionMailer::Base.deliveries.clear
  end

  # Make sure invalid user attributes do not pass
  test "invalid signup attributes" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { email: "",
			       password: "password123",
			       password_confirmation: "password123" }
    end
    assert_template 'users/new'
  end

  # Make sure valid user attributes do pass
  test "valid signup attributes with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { email: "test_user@example.com",
			       password: "foobar",
			       password_confirmation: "foobar" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as user			# before activation
    assert_not is_logged_in?
    get edit_account_activation_path('invalid token')
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
