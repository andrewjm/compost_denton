class UsersController < ApplicationController

  # Grab user by id and render the users/show view
  # Accessible via example.com/users/:id -- ie. (example.com/users/1)
  def show
    @user = User.find(params[:id]) 
  end

  # Create @user object in memory, render new view
  def new
    @user = User.new
  end

  # Accept hash of params from signup form, save user into db
  def create
    @user = User.new(user_params)	# fill @user attributes with hash from form
    if @user.save			# attempt to save @user into db
      flash[:success] = "Welcome to Compost Denton"
      redirect_to @user
    else				# if fails, reload the signup page
      render 'new'
    end
  end

  private

    # Setup strong parameters for user hash from signup form
    def user_params
      params.require(:user).permit( :name,
				    :email,
				    :password,
				    :password_confirmation )
    end
end
