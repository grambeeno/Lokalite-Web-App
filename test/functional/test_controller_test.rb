require 'test_helper'

class TestControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "should get Dao Test Index Page" do
    get :index
    assert_response :success
  end

end
