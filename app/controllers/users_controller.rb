class UsersController < ApplicationController

  ##
  ## AUTHORIZATION FILTERS

  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,	 only: :destroy

  ##
  ## CREATE

  # Create @user object in memory, render new view
  def new
    @user = User.new
  end

  # Accept hash of params from signup form, save user into db
  def create
    @user = User.new(user_params)       # fill @user attributes with hash from form
    if @user.save                       # attempt to save @user into db
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_url
      # log_in @user
      # flash[:success] = "Welcome to Compost Denton"
      # redirect_to @user
    else                                # if fails, reload the signup page
      render 'new'
    end
  end

  ##
  ## READ

  # Grab user by id and render the users/show view
  # Accessible via example.com/users/:id -- ie. (example.com/users/1)
  def show
    @user = User.find(params[:id])
    @user_weight = Weight.where(user_id: @user.id).sum(:weight)
    @members = @user.members.paginate(page: params[:page])
  end

  # Display users in pagination
  def index
    @users = User.paginate(page: params[:page])
  end

  ##
  ## UPDATE

  # Grad user data to pass along to the edit page
  def edit
    @user = User.find(params[:id])
  end

  # User updates own attributes
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  ##
  ## DESTROY

  # Delete User
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User Deleted"
    redirect_to users_url
  end

  private

    # Setup strong parameters for user hash from signup form
    def user_params
      params.require(:user).permit( :email,
				    :password,
				    :password_confirmation,
				    :address_line_one )
    end

    # Check if logged in
#    def logged_in_user
#      unless logged_in?
#        store_location			# app/helpers/session_helper.rb
#        flash[:danger] = "Please log in"
#        redirect_to login_url
#      end
#    end

    # Confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)	# app/helpers/session_helper.rb
    end

    # Checks it current user is an admin
    def admin_user
      redirect_to root_url unless current_user.admin?
    end

end
