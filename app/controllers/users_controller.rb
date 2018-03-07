class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  skip_before_action :authenticate_request, only: [:register, :reset_password]

  def show
    if @current_user.id == @user.id
      render json: {results: {user: @user.as_json(only: [:id, :phone, :jwt_token])}, statusCode: 200, statusMsg: "获取个人资料成功！", success: "true"}
    else
      render json: {results: {}, statusCode: 403, statusMsg: "没有权限", success: "false"}
    end
  end

  # {user: {phone: xxx, password: xxx}, msg_token: xxx}
  def register
    phone = user_params[:phone]
    @msg_token = MsgToken.where(account: phone).last
    if @msg_token && @msg_token.value == params[:msg_token][:value]
      @user = User.find_by_phone(phone)
      if @user
        return render json: {results: {}, statusCode: 500, statusMsg: "当前手机号已注册，请直接登陆！", success: "false"}
      end
      @user = User.create!(phone: phone, password: user_params[:password])
      results = User.auth_jwt_token(phone, user_params[:password])
      render json: {
        results: {user: results[0].as_json(only: [:id, :phone, :jwt_token]).merge!({exp: results[1]})},
        statusCode: 200, statusMsg: "注册成功", success: "true" }
    else
      render json: {results: {}, statusCode: 500, statusMsg: "短信验证码错误！", success: "false"}
    end
  end

  # {user: {phone: xxx, password: xxx}, msg_token: xxx}
  def reset_password
    phone = user_params[:phone]
    @msg_token = MsgToken.where(account: phone).last
    if @msg_token && @msg_token.value == params[:msg_token][:value]
      @user = User.find_by_phone(phone)
      unless @user
        return render json: {results: {}, statusCode: 500, statusMsg: "当前手机号未注册，请注册！", success: "false"}
      end
      @user.update!(password: user_params[:password])
      results = User.auth_jwt_token(phone, user_params[:password])
      render json: {
        results: {user: results[0].as_json(only: [:id, :phone, :jwt_token]).merge!({exp: results[1]})},
        statusCode: 200, statusMsg: "重置密码成功！", success: "true" }
    else
      render json: {results: {}, statusCode: 500, statusMsg: "短信验证码错误！", success: "false"}
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:phone, :password, :jwt_token)
  end
end
