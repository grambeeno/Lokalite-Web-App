require 'test_helper'

class StatusTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "create a status" do
    assert_difference 'Status.count',1 do
        Status.create(:context_type => "Organization",
        :context_id => 1,
        :content => "Tacos and Tacos and Tacos - get them on the Hill."
        )
    end
  end

end
