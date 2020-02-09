class Api::V1::ListsController < ApplicationController
  before_action :authenticated?
  before_action :find_list, only: %i[show update destroy]

  # GET /lists
  def index
    render json: self.current_user.lists
  end

  # POST /lists
  def create
    @list = current_user.lists.new(list_params)

    if @list.save
      render json: @list, status: :created
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  # GET /lists/1
  def show
    render json: @list
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      render json: @list, status: :ok
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lists/1
  def destroy
    @list.destroy
    head 204
  end

  private

  # Ensure client is authenticated
  def authenticated?
    head :forbidden unless self.current_user
  end

  # White list parameters
  def list_params
    params.require(:list).permit(:name)
  end

  # Find requested list by id
  def find_list
    head :not_found unless @list = current_user.lists.find_by(id: params[:id])
  end
end
