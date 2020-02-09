require 'test_helper'

class TodoTest < ActiveSupport::TestCase
  test "todos without a title should not be valid" do
    todo = todos(:one)
    todo.title = nil
    assert_not todo.valid?
  end
  
  test "todos without a status should not be valid" do
    todo = todos(:one)
    todo.status = nil
    assert_not todo.valid?
  end
end
