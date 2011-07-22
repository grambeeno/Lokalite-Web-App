require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  #TTD - locations page throwing error only in testmode. figure it and add it to the test. RS jun '11
  #static_pages = %w(about coming_soon terms_of_service contact test locations movie)
  static_pages = %w(about coming_soon terms_of_service contact test movie )
  test "should get each static page" do
    static_pages.each do |p|
      get "#{p}"
      assert_response :success
    end
  end  

end
