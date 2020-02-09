class Api::V1::TodosController < ApplicationController
  before_action :authenticated?
  before_action :find_list
  before_action :find_todo, only: %i[show update destroy]

  # GET /lists/1/todos
  def index
    render json: self.current_user.todos
  end

  # POST /lists/1/todos
  def create
    @todo = @list.todos.new(todo_params)

    if @todo.save
      render json: @todo, status: :created
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # GET /lists/1/todos/1
  def show
    render json: @todo
  end

  # PATCH/PUT /lists/1/todos/1
  def update
    # If the list_id is being updated (i.e. the todo is being
    # moved to a different list), validate the new list.
    if todo_params.has_key? :list_id
      head :not_found and return unless self.current_user.lists.find_by(id: todo_params[:list_id])
    end

    if @todo.update(todo_params)
      render json: @todo, status: :ok
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lists/1/todos/1
  def destroy
    @todo.destroy
    head 204
  end

  private

  # Ensure client is authenticated
  def authenticated?
    head :forbidden unless self.current_user
  end

  # White list parameters
  def todo_params
    params.require(:todo).permit(:title, :status, :list_id)
  end

  # Find the requested list by id
  def find_list
    head :not_found unless @list = current_user.lists.find_by(id: params[:list_id])
  end

  # Find the requested todo by id
  def find_todo
    head :not_found unless @todo = @list.todos.find_by(id: params[:id])
  end
end
