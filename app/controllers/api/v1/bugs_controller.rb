class Api::V1::BugsController < ApplicationController

  # GET /bugs
  def index
    @bugs = Bug.all
    json_response(@bugs)
  end

  # POST /bugs
  def create
    @bug = Bug.new(bug_params)
    @state = State.new(state_params)
    if !@bug.valid?
      raise ActiveRecord::RecordInvalid.new(@bug)
    end
    @bug.state = @state
    @state.bug = @bug
    if !@state.valid?
      raise ActiveRecord::RecordInvalid.new(@state)
    end
    @bug.number = get_bug_id bug_params[:app_token]
    Publisher.publish(@bug.to_json(include: :state))
    json_response({app_token: @bug.app_token, number: @bug.number}, :created)
  end

  # GET /bugs/:number
  def show
    @bug = Bug.find_by!(number: params[:number], app_token: params[:app_token])
    json_response(@bug.to_json(include: :state))
  end

  # PUT /bugs/:number
  def update
    @bug = Bug.find_by!(number: params[:number], app_token: params[:app_token])
    @bug.update(bug_params)
    # TODO: Update state too
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

  def state_params
    # whitelist params
    params[:state].permit(:device, :os, :os, :memory, :storage)
  end

  def get_bug_id(app_token)
    $redis.incr("bug_token_counter$#{app_token}")
  end
end
