class BugsController < ApplicationController

  # GET /bugs
  def index
    @bugs = Bug.all
    json_response(@bugs)
  end

  # POST /bugs
  def create
    @bug = Bug.create!(bug_params)
    json_response(@bug, :created)
  end

  # GET /bugs/:number
  def show
    @bug = Bug.find_by(number: params[:number], app_token: params[:app_token])
    json_response(@bug)
  end

  # PUT /bugs/:number
  def update
    @bug = Bug.find_by(number: params[:number], app_token: params[:app_token])
    @bug.update(bug_params)
    head :no_content
  end

  # DELETE /bugs/:number
  def destroy
    @bug = Bug.find_by(number: params[:number], app_token: params[:app_token])
    @bug.destroy
    head :no_content
  end

  private

  def bug_params
    # whitelist params
    params.permit(:app_token, :status, :priority, :comment )
  end

  def set_bug
    @bug = Bug.find_by(number: params[:number], app_token: params[:app_token])
  end
end
