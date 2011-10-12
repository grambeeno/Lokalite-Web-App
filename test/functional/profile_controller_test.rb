require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "should get datebook" do
    get :datebook
    assert_response :success
  end

  test "should get plans" do
    get :plans
    assert_response :success
  end

  test "should get friends" do
    get :friends
    assert_response :success
  end

end
