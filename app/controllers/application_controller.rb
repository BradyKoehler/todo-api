class ApplicationController < ActionController::API
  # Use our JWT authentication setup
  include Authenticable
end
