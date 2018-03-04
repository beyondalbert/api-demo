class User < ApplicationRecord
  has_secure_password

  def self.auth_jwt_token(phone, password)
    user = find_by_phone(phone)
    if user && user.authenticate(password)
      unless user.jwt_token && JsonWebToken.decode(user.jwt_token)[:exp] > Time.now.to_i
        user.update!(jwt_token: JsonWebToken.encode(user_id: user.id))
      end
      [user, JsonWebToken.decode(user.jwt_token)[:exp]]
    else
      nil
    end
  end
end
