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

  test "create and verify Status" do
    sta = Status.create(
      :context_type => "Organization",
        :context_id => 1,
        :content => "Tacos Tacos Tacos - get the best deal in town on the Hill."
    )
    assert_equal(statuses(:one).context_type, sta.context_type)
    assert_equal(statuses(:one).context_id, sta.context_id)
    assert_equal(statuses(:one).content, sta.content)
    assert_not_equal(statuses(:two).content, sta.content)
  end
  
  
end
