class StaffsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @staffs = Staff.all
    respond_with(@staffs)
  end

  def show
    respond_with(@staff)
  end

  def new
    @staff = Staff.new
    respond_with(@staff)
  end

  def edit
  end

  def create
    @staff = Staff.new(staff_params)
    @staff.save
    respond_with(@staff)
  end

  def update
    Rails.logger.error("staff params in update #{staff_params.inspect}")
    @staff.update(staff_params)
    respond_with(@staff)
  end

  def destroy
    @staff.destroy
    respond_with(@staff)
  end

  private
    def set_staff
      @staff = Staff.find(params[:id])
    end

    def staff_params
      params.require(:staff).permit(:event_id, :position_id, :shift_id, :permanent_user)
    end
end
