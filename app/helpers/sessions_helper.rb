module SessionsHelper

  ##
  ## SESSION HANDLING

  # Create a temporary session
  def log_in(user)
    session[:user_id] = user.id
  end

  # Destroy a session
  def log_out
    forget(current_user)	# Destroy permanent cookie
    session.delete(:user_id)
    @current_user = nil
  end

  ##
  ## COOKIE HANDLING

  # Create a permanent cookie for a multi-use session
  def remember(user)
    user.remember						# defined in user model
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Destroy a permanent cookie
  def forget(user)
    user.forget							# defined in user model
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  ##
  ## MISC. SESSION UTILITIES

  # Returns current user if one exists
  def current_user
    if (user_id = session[:user_id])				# if a session exists
      @current_user ||= User.find_by(id: user_id)		# set current_uer
    elsif (user_id = cookies.signed[:user_id])			# elsif a cookie exists
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])	# if user exists and we have the right cookie
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user 
  def current_user?(user)
    user == current_user
  end

  # Checks if a user is logged in
  def logged_in?
    !current_user.nil?
  end

  ##
  ## FRIENDLY FORWARDING

  # Redirect to stored URL or the default
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores URL trying to be accessed
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
