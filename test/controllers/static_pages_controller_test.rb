require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get Home" do
    get :Home
    assert_response :success
  end

  test "should get About" do
    get :About
    assert_response :success
  end

  test "should get Faq" do
    get :Faq
    assert_response :success
  end

  test "should get Partners" do
    get :Partners
    assert_response :success
  end

  test "should get Pricing" do
    get :Pricing
    assert_response :success
  end

  test "should get Contact" do
    get :Contact
    assert_response :success
  end

  test "should get Terms" do
    get :Terms
    assert_response :success
  end
end
