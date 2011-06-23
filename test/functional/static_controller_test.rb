require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "should get about" do
    get 'about'
    assert_response :success
  end
  
end
