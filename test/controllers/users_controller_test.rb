require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @admin = users(:andrew)
    @user  = users(:thomas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@user)
    get :edit, id: @admin
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@user)
    patch :update, id: @admin, user: { name: @user.name, email: @user.email }
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in as admin" do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @admin
    end
    assert_redirected_to root_url
  end
end
