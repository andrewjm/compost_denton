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
    if @weight.save
      flash[:success] = "Weight logged!"
      redirect_to root_url
    else
      flash[:danger] = "Date was not posted!"
      redirect_to root_url
    end
  end

  private

    def weight_params
      params.require(:weight).permit(:weight, :member_id)
    end

end
