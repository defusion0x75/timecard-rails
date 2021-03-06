class WorkloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workload, only: [:edit, :update, :destroy, :stop]
  def index
    if params[:user_id].present?
      if params[:day].present?
        date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
        @workloads = current_user.workloads.daily(date).complete
      else
        @workloads = current_user.workloads.complete
      end
    end

    respond_to do |format|
      format.json
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @workload.update(workload_params)
        format.html { redirect_to @workload.issue, notice: 'Work log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @workload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @workload.destroy
    respond_to do |format|
      format.html { redirect_to @workload.issue }
      format.json { head :no_content }
    end
  end

  def start
    if current_user.workloads.running?
      @prev_issue = current_user.working_issue
      current_user.running_workload.update!(end_at: Time.now.utc)
    end
    @issue = Issue.find(params[:issue_id])
    @workload = @issue.workloads.build(start_at: Time.now.utc, user_id: current_user.id)

    if @workload.save
      respond_to do |format|
        format.html { redirect_to @issue, notice: 'Work log was successfully started.' }
        format.js
        format.json { render action: 'start', status: :created, location: @workload }
      end
    end
  end

  def stop
    if @workload.update_attribute(:end_at, Time.now.utc)
      respond_to do |format|
        format.html { redirect_to @workload.issue, notice: 'Work log was successfully stopped.' }
        format.js
        format.json { render action: 'stop', status: :created, location: @workload }
      end
    end
  end

  private

  def set_workload
    @workload = Workload.find(params[:id])
  end

  def workload_params
    params.require(:workload).permit(:start_at, :end_at, :issue_id, :user_id)
  end
end
