class Api::V1::UsersController < ApplicationController
  before_action :find_user, only: %i[show update destroy]
  before_action :authenticated?, except: :create

  # GET /users/1
  def show
    head :not_found and return if @user.id != current_user.id
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    head 204
  end

  private

  # White list user parameters
  def user_params
    params.require(:user).permit(:email, :password)
  end

  # Find requested user by passed ID
  def find_user
    @user = User.find(params[:id])
  end

  # Ensure client is authenticated
  def authenticated?
    head :forbidden unless self.current_user
  end
end
