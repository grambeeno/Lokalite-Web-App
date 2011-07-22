require 'test_helper'

class RootControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "should get Lokalite Landing Page" do
    get :index
    assert_response :redirect    #index goes to events_path - for now
  end

end
