def user_logged
    user = nil
    if session[:admin]
      user = User.find_by(nickname: session[:admin])
    end
    user
  end

def current_user
  User.find_by(nickname: session[:admin])
end