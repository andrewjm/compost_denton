require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  # Grab dummy user from fixtures
  def setup
    @user = users(:andrew)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:                  '',
				    email:                 'invalid@foo',
				    password:              'foo',
				    password_confirmation: 'bar' }
    assert_template 'users/edit'
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = 'New Name'
    email = 'hi@test.com'
    patch user_path(@user), user: { name:                  name,
				    email:		   email,
				    password:		   '',
				    password_confirmation: '' }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = 'New Name'
    email = 'hi@test.com'
    patch user_path(@user), user: { name:                  name,
                                    email:                 email,
                                    password:              '',
                                    password_confirmation: '' }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end
end
