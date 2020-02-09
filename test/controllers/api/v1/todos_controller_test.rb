require 'test_helper'

class Api::V1::TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = lists(:one)
    @todo = todos(:one)
  end

  ### INDEX

  test "should show todos" do
    get api_v1_list_todos_url(@list),
      headers: { Authorization: JsonWebToken.encode(user_id: users(:one).id) },
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal 1, json_response.length
  end

  test "should not show todos for unauthenticated user" do
    get api_v1_list_todos_url(@list), as: :json
    assert_response :forbidden
  end

  ### CREATE

  test "should create todo" do
    assert_difference("Todo.count") do
      post api_v1_list_todos_url(@list),
        params: { todo: { title: "A New Task" } },
        headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) },
        as: :json
    end
    assert_response :created

    json_response = JSON.parse(self.response.body)
    assert_equal "A New Task", json_response["title"]
  end

  test "should not create todo without a title" do
    assert_no_difference("Todo.count") do
      post api_v1_list_todos_url(@list),
        params: { todo: { title: nil } },
        headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) },
        as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should not create todo for unauthenticated user" do
    assert_no_difference("Todo.count") do
      post api_v1_list_todos_url(@list),
        params: { todo: { title: "A Valid Title" } },
        as: :json
    end
    assert_response :forbidden
  end

  ### SHOW

  test "should show todo" do
    get api_v1_list_todo_url(@list, @todo),
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) },
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal @todo.title, json_response["title"]
  end

  test "should not show todo for incorrect authenticated user" do
    get api_v1_list_todo_url(@list, @todo), 
      headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not show todo for unauthenticated user" do
    get api_v1_list_todo_url(@list, @todo), as: :json
    assert_response :forbidden
  end

  ### UPDATE

  test "should update todo" do
    patch api_v1_list_todo_url(@list, @todo),
      params: { todo: { title: "A New Title", status: "complete" } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :success

    json_response = JSON.parse(self.response.body)
    assert_equal "A New Title", json_response["title"]
  end

  test "should not update todo with invalid title" do
    patch api_v1_list_todo_url(@list, @todo),
      params: { todo: { title: nil } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :unprocessable_entity
  end

  test "should not update todo with invalid status" do
    patch api_v1_list_todo_url(@list, @todo),
      params: { todo: { status: nil } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :unprocessable_entity
  end

  test "should not update todo with blank list id" do
    patch api_v1_list_todo_url(@list, @todo),
      params: { todo: { list_id: nil } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not update todo with invalid list id" do
    patch api_v1_list_todo_url(@list, @todo),
      params: { todo: { list_id: lists(:three).id } },
      headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not update todo for incorrect authenticated user" do
    patch api_v1_list_todo_url(@list, @todo), 
      headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) }, 
      as: :json
    assert_response :not_found
  end

  test "should not update todo for unauthenticated user" do
    patch api_v1_list_todo_url(@list, @todo), as: :json
    assert_response :forbidden
  end

  ### DESTROY

  test "should destroy todo" do
    assert_difference("Todo.count", -1) do
      delete api_v1_list_todo_url(@list, @todo),
        headers: { Authorization: JsonWebToken.encode(user_id: @list.user_id) },
        as: :json
    end
    assert_response :no_content
  end

  test "should not destroy todo for invalid user" do
    assert_no_difference("Todo.count") do
      delete api_v1_list_todo_url(@list, @todo),
        headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id) },
        as: :json
    end
    assert_response :not_found
  end

  test "should not destroy todo for unauthenticated user" do
    assert_no_difference("Todo.count") do
      delete api_v1_list_todo_url(@list, @todo), as: :json
    end
    assert_response :forbidden
  end
end
