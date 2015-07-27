class SessionsController < ApplicationController

  def new
    if logged_in?
      redirect_to current_user
    end
  end

  # Accepts params hash from login form, creates a new session on success
  def create
    user = User.find_by( email: params[:session][:email].downcase )		# find by downcased email value in session hash
    if user && user.authenticate( params[:session][:password] )			# if user exists and has proper email pw combo
      if user.activated?
        log_in user								# create the session (function lives in session_helper.rb)
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)	# if remember is checked, create permanent cookie
        redirect_back_or user
      else
        message = "Account not yet activated. Check your email for activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email / password combination"
      render 'new'
    end
  end

  # Delete the session
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
