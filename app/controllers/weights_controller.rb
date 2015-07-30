class WeightsController < ApplicationController
  before_action :logged_in_user, only: [:create]
  before_action :correct_user, only: [:create]

  def index
  end

  def new
  end

  def create
    @weight = current_user.weights.build(weight_params)
    @member = Member.find(weight_params[:member_id])
    if @weight.save
      flash[:success] = "#{@weight.weight} lbs logged for #{@member.first_name} #{@member.last_name}!"
      redirect_to user_members_path
    else
      flash[:danger] = "Error occured, weight not logged!"
      redirect_to user_members_path
    end
  end

  private

    def weight_params
      params.require(:weight).permit(:weight, :member_id)
    end

    # Confirms the correct user
    def correct_user
      @user = User.find(params[:user_id])
      redirect_to root_url unless current_user?(@user)  # app/helpers/session_helper.rb
    end

end
