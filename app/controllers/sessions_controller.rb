class SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :captcha, :send_msg_token]

  def create
    @captcha = Captcha.find(params[:captcha][:id])
    if @captcha && @captcha.value.downcase == params[:captcha][:value].downcase
      results = User.auth_jwt_token(params[:user][:phone], params[:user][:password])
    else
      statusMsg = "图片验证码错误！"
    end

    if results
      render json: { results: {user: results[0].as_json(only: [:id, :phone, :jwt_token]).merge!({exp: results[1]})}, statusCode: 200, statusMsg: '登录成功', success: "true" }
    else
      render json: { results: {}, statusCode: 403, statusMsg: statusMsg || "账户或密码错误！", success: "false" }
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
    statusMsg = nil
    @captcha = Captcha.find(params[:captcha][:id])
    if @captcha && @captcha.value.downcase == params[:captcha][:value].downcase
      @msg_token = MsgToken.create!(account: params[:user][:phone], value: rand.to_s[2..7])

      # 5分钟后自动删除短信验证码信息
      MsgTokensCleanupJob.set(wait: 5.minute).perform_later(@msg_token)
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
