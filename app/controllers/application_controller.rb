class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  private
  def authenticate_request
    p request.headers['Authorization']
    if request.headers['Authorization'].present?
      jwt_token = request.headers['Authorization'].split(' ').last
      jwt_info = JsonWebToken.decode(jwt_token)
      if jwt_info
        @current_user ||= User.find(jwt_info[:user_id])
      end
    end
    render json: {results: {}, statusCode: 403, statusMsg: "没有权限", success: "false" }, status: 401 unless @current_user
  end
end
