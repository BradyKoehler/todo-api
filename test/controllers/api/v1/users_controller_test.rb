require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  ### CREATE

  test "should create user" do
    assert_difference("User.count") do
      post api_v1_users_url, 
        params: { user: { email: 'test@bradykoehler.com', password: '123456' } }, 
        as: :json
    end
    assert_response :created
  end

  test "should not create user with taken email" do
    assert_no_difference("User.count") do
      post api_v1_users_url, 
        params: { user: { email: @user.email, password: '123456' } }, 
        as: :json
    end
    assert_response :unprocessable_entity
  end

  ### READ

  test "should show user" do
    get api_v1_user_url(@user), as: :json
    assert_response :success

    # Test to ensure response contains the correct email
    json_response = JSON.parse(self.response.body)
    assert_equal @user.email, json_response['email']
  end

  ### UPDATE

  test "should update user" do
    patch api_v1_user_url(@user), 
      params: { user: { email: @user.email } },
      headers: { Authorization: JsonWebToken.encode(user_id: @user.id) }, 
      as: :json
    assert_response :success
  end

  test "should forbid update user" do
    patch api_v1_user_url(@user),
      params: { user: { email: @user.email } },
      as: :json
    assert_response :forbidden
  end

  test "should not update user when invalid params are sent" do
    patch api_v1_user_url(@user), 
      params: { user: { email: 'bad_email' } },
      headers: { Authorization: JsonWebToken.encode(user_id: @user.id) }, 
      as: :json
    assert_response :unprocessable_entity
  end

  ### DESTROY

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete api_v1_user_url(@user), 
        headers: { Authorization: JsonWebToken.encode(user_id: @user.id) },
        as: :json
    end
    assert_response :no_content
  end

  test "destroy user should destroy linked lists" do
    assert_difference("List.count", -2) do
      users(:one).destroy
    end
  end

  test "should forbid destroy user" do
    assert_no_difference("User.count") do
      delete api_v1_user_url(@user), as: :json
    end
    assert_response :forbidden
  end
end
