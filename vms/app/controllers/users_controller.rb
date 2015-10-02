class UsersController < ApplicationController
  # this controller is for admins to edit other users. 
  # For users to edit their own information, see the devise paths
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def show
    @user = User.includes(:qualifications, :schedules, :offers).find(params[:id])
    @qualifications = @user.qualifications
    @schedules = @user.schedules
    @offers = @user.offers
  end
  
  def edit
    @user = User.find(params[:id])
    @roles = Role.all
  end
  
  def update
    params[:user][:role_ids] ||= []
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  

  private  
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :member_number, role_ids: [])
    end
end