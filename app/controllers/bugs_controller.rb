class BugsController < ApplicationController

  # GET /bugs
  def index
    @bugs = Bug.all
    json_response(@bugs)
  end

  # POST /bugs
  def create
    @bug = Bug.new(bug_params)
    if !@bug.valid?
      raise ActiveRecord::RecordInvalid.new(@bug)
    end
    @bug.number = get_bug_id bug_params[:app_token]
    # @bug = Bug.create!(bug_params)
    Publisher.publish(@bug.attributes)
    json_response({app_token: @bug.app_token, number: @bug.number}, :created)
  end

  # GET /bugs/:number
  def show
    @bug = Bug.find_by!(number: params[:number], app_token: params[:app_token])
    json_response(@bug)
  end

  # PUT /bugs/:number
  def update
    @bug = Bug.find_by!(number: params[:number], app_token: params[:app_token])
    @bug.update(bug_params)
    head :no_content
  end

  # DELETE /bugs/:number
  def destroy
    @bug = Bug.find_by!(number: params[:number], app_token: params[:app_token])
    @bug.destroy
    head :no_content
  end

  private

  def bug_params
    # whitelist params
    params.permit(:app_token, :status, :priority, :comment)
  end

  def get_bug_id(app_token)
    $redis.incr("bug_token_counter$#{app_token}")
  end
end
