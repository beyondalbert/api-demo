class AuthenticateUser
  prepend SimpleCommand

  def initialize(phone, password)
    @phone = phone
    @password = password
  end

  def call
    if user
      p Time.now.to_i
      p JsonWebToken.decode(user.jwt_token)[:exp]
      if JsonWebToken.decode(user.jwt_token)[:exp] > Time.now.to_i
        user.jwt_token
      else
        JsonWebToken.encode(user_id: user.id)
      end
    end
  end

  private

  attr_accessor :phone, :password

  def user
    user = User.find_by_phone(phone)
    return user if user && user.authenticate(password)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
