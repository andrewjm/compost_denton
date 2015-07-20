class MembersController < ApplicationController
  # THESE NEED SOME WORK BEFORE THEY CAN BE UNCOMMENTED!!!
  #before_action :logged_in_user, only: [:create]
  #before_action :correct_user

  # Display members in pagination
  def index
    @user = User.find(params[:user_id])
    @lat = cookies[:latitudine].nil? ? '0.00' : cookies[:latitudine]
    @long = cookies[:longitudine].nil? ? '0.00' : cookies[:longitudine]

    # Check for 'order' param in url
    if params.has_key?(:order)
      if params[:order] == 'first'
        # Order by first name
        @members = @user.members.order("LOWER(first\_name) asc").paginate(page: params[:page])
      elsif params[:order] == 'last'
        # Order by last name
        @members = @user.members.order("LOWER(last\_name) asc").paginate(page: params[:page])
      elsif params[:order] == 'locale'
        # Order by location
        @members = @user.members.near([@lat, @long], 50).paginate(page: params[:page])
      end
    else
      # If no 'order' param, default to order by location
      @members = @user.members.near([@lat, @long], 50).paginate(page: params[:page])
    end
  end

  # Member profile
  def show
    @member = Member.find(params[:id])
    @member_weight = Weight.where(member_id: @member.id).sum(:weight)
    @weight = Weight.new
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
