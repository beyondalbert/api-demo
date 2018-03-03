class MsgTokensCleanupJob < ApplicationJob
  queue_as :default

  def perform(msg_token)
    # Do something later
    msg_token.destroy!
  end
end
