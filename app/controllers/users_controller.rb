class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    if @current_user.id == @user.id
      render json: {results: {user: @user.as_json(only: [:id, :phone, :jwt_token])}, statusCode: 200, statusMsg: "获取个人资料成功！", success: "true"}
    else
      render json: {results: {}, statusCode: 403, statusMsg: "没有权限", success: "false"}
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:phone, :jwt_token)
  end
end
