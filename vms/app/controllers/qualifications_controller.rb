class QualificationsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  def index
    if (params[:user_id]) then
      @qualifications = User.find(params[:user_id]).qualifications
    else
      @qualifications = Qualification.all
    end
    respond_with(@qualifications)
  end

  def show
    respond_with(@qualification)
  end

  def new
    @qualification = Qualification.new
    respond_with(@qualification)
  end

  def edit
  end

  def create
    @qualification = Qualification.new(qualification_params)
    @qualification.save
    respond_with(@qualification)
  end

  def update
    @qualification.update(qualification_params)
    respond_with(@qualification)
  end

  def destroy
    @qualification.destroy
    respond_with(@qualification)
  end

  private
    def set_qualification
      @qualification = Qualification.find(params[:id])
    end

    def qualification_params
      params.require(:qualification).permit(:user_id, :position_id, :status, :count)
    end
end
