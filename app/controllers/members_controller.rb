class MembersController < ApplicationController
  # THESE NEED SOME WORK BEFORE THEY CAN BE UNCOMMENTED!!!
  #before_action :logged_in_user, only: [:create]
  #before_action :correct_user

  # Display members in pagination
  def index
    @user = User.find(params[:user_id])
    @members = @user.members.paginate(page: params[:page])
  end

  # Member profile
  def show
    @member = Member.find(params[:id])
  end

  # Make new member
  def new
    @member = Member.new
  end

  def create
    @member = Member.new
    @member = current_user.members.build(member_params)
    if @member.save
      flash[:success] = "Member created"
      redirect_to root_url
    end
  end

  private

    def member_params
      params.require(:member).permit(:first_name, :last_name, :address_line_one, :address_line_two)
    end
end
