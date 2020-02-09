require 'test_helper'

class Api::V1::ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = lists(:one)
  end

  ### INDEX

  test "should show lists for correct authenticated user" do
    get api_v1_lists_url(), 
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal 2, json_response.length
  end

  test "should not show lists for unauthenticated user" do
    get api_v1_lists_url(), as: :json
    assert_response :forbidden
  end

  ### CREATE

  test "should create list" do
    assert_difference("List.count") do
      post api_v1_lists_url,
        params: { list: { name: "A Random Name" } },
        headers: { Authorization: JsonWebToken.encode(user_id: users(:one).id) },
        as: :json
    end
    assert_response :created

    json_response = JSON.parse(self.response.body)
    assert_equal "A Random Name", json_response["name"]
  end

  test "should not create list without a name" do
    assert_no_difference("List.count") do
      post api_v1_lists_url,
        params: { list: { name: nil } },
        headers: { Authorization: JsonWebToken.encode(user_id: users(:one).id) },
        as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should not create list for unauthenticated user" do
    assert_no_difference("List.count") do
      post api_v1_lists_url,
        params: { list: { name: "A Valid Name" } },
        as: :json
    end
    assert_response :forbidden
  end

  ### SHOW

  test "should show list for authenticated user" do
    get api_v1_list_url(@list), 
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal @list.name, json_response["name"]
  end

  test "should not show list for incorrect authenticated user" do
    get api_v1_list_url(@list), 
      headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not show list for unauthenticated user" do
    get api_v1_list_url(@list), as: :json
    assert_response :forbidden
  end

  ### UPDATE

  test "should update list" do
    patch api_v1_list_url(@list),
      params: { list: { name: "A New Name" } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal "A New Name", json_response["name"]
  end

  test "should not update list with invalid name" do
    patch api_v1_list_url(@list),
      params: { list: { name: nil } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :unprocessable_entity
  end

  test "should not update list for incorrect authenticated user" do
    patch api_v1_list_url(@list), 
      headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not update list for unauthenticated user" do
    patch api_v1_list_url(@list), as: :json
    assert_response :forbidden
  end

  ### DESTROY

  test "should destroy list" do
    assert_difference("List.count", -1) do
      delete api_v1_list_url(@list),
        headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) },
        as: :json
    end
    assert_response :no_content
  end

  test "destroy list should destroy linked todos" do
    assert_difference("Todo.count", -1) do
      lists(:one).destroy
    end
  end

  test "should not destroy list for invalid user" do
    assert_no_difference("List.count") do
      delete api_v1_list_url(@list),
        headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) },
        as: :json
    end
    assert_response :not_found
  end

  test "should not destroy list for unauthenticated user" do
    assert_no_difference("List.count") do
      delete api_v1_list_url(@list), as: :json
    end
    assert_response :forbidden
  end
end
