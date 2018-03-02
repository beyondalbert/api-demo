class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    command = AuthenticateUser.call(params[:phone], params[:password])

    if command.success?
      user = User.find_by_phone(params[:phone])
      user.update!(jwt_token: command.result)

      render json: { results: {user: user.as_json(only: [:id, :phone, :jwt_token]).merge!({exp: JsonWebToken.decode(user.jwt_token)[:exp]})}, statusCode: 200, statusMsg: '登录成功', success: "true" }
    else
      render json: { results: {}, statusCode: 401, statusMsg: command.errors, success: "false" }, status: :unauthorized
    end
  end
end
