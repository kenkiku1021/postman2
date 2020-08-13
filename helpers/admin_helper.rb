module AdminHelper
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Postman2-Admin"'
    halt 401, "Not Authorized\n"
  end

  def authorized?
    if session[:admin_auth]
      return true
    else
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials and auth(@auth.credentials[0], @auth.credentials[1])
    end
  end

  def auth(user, password)
    config = AppConfig.instance
    config.admin_auth(user, password)
  end

  def get_user
    user = User.find_by_username(params[:username])
    if user.nil?
      raise "指定されたユーザは存在しません。"
    end
    user
  end
end