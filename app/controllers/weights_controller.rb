class WeightsController < ApplicationController
  #before_action :logged_in_user, only: [:create]
  #before_action :correct_user

  def index
  end

  def new
  end

  def create
    @weight = Weight.new
    @weight = current_user.weights.build(weight_params)
    @member = Member.find_by(id: weight_params[:member_id])
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

end
