class SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :captcha, :send_msg_token]

  def create
    user = User.authenticate(params[:phone], params[:password])

    if user
      render json: { results: {user: user.as_json(only: [:id, :phone, :jwt_token]).merge!({exp: JsonWebToken.decode(user.jwt_token)[:exp]})}, statusCode: 200, statusMsg: '登录成功', success: "true" }
    else
      render json: { results: {}, statusCode: 401, statusMsg: command.errors, success: "false" }, status: :unauthorized
    end
  end

  # 用户退出逻辑
  def destroy
    @current_user.update!(jwt_token: nil)
    render json: { results: {}, statusCode: 200, statusMsg: "退出成功！", success: "true" }
  end

  def captcha
    text = SecureRandom.hex(2).upcase
    base64Image = CaptchaGenerator.g text, 126, 40
    @captcha = Captcha.create!({value: text, image_base64: base64Image})
    CaptchasCleanupJob.set(wait: 3.minute).perform_later(@captcha)
    render json: { results: {captcha: @captcha.as_json(only: [:id, :image_base64])}, statusCode: 200, statusMsg: "获取验证码图片成功！", success: "true" }
  end

  # {captcha: {id: xxx, value: xxx}, user: {phone: xxx}}
  def send_msg_token
    p params
    statusMsg = nil
    @captcha = Captcha.find(params[:captcha][:id])
    if @captcha && @captcha.value.downcase == params[:captcha][:value].downcase
      @msg_token = MsgToken.create!(account: params[:user][:phone], value: rand.to_s[2..7])

      # 3分钟后自动删除短信验证码信息
      MsgTokensCleanupJob.set(wait: 1.minute).perform_later(@msg_token)
      # 调用发送验证码接口进行短信验证码发送

    else
      statusMsg = "图片验证码不正确！"
    end

    if @msg_token
      render json: { results: {}, statusCode: 200, statusMsg: "验证码发送成功！", success: "true" }
    else
      render json: { results: {}, statusCode: 500, statusMsg: statusMsg || "验证码发送失败，请重新发送！", success: "false" }
    end
  end
end
