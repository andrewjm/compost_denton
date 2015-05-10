require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # Make sure invalid user attributes do not pass
  test "invalid signup attributes" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
			       email: "hello@example.com",
			       password: "password123",
			       password_confirmation: "password123" }
    end
    assert_template 'users/new'
  end

  # Make sure valid user attributes do pass
  test "valid signup attributes" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Example User",
					    email: "test_user@example.com",
					    password: "foobar",
					    password_confirmation: "foobar" }
    end
    assert_template 'users/show'
    assert is_logged_in?
  end

end
