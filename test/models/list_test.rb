require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test "lists without a name should not be valid" do
    list = lists(:one)
    list.name = nil
    assert_not list.valid?
  end
end
