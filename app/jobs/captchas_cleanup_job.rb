class CaptchasCleanupJob < ApplicationJob
  queue_as :default

  def perform(captcha)
    # 3分钟后自动删除生成的验证码图片
    captcha.destroy!
  end
end
