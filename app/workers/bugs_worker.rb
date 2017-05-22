class BugsWorker
  include Sneakers::Worker
  # This worker will connect to "instaapi.bugs" queue
  # env is set to nil since by default the actuall queue name would be
  # "instaapi.bugs_development"
  from_queue "instaapi.bugs", env: nil

  # work method receives message payload in raw format
  # in our case it is JSON encoded string
  # which we can pass to RecentPosts service without
  # changes
  def work(raw_post)
    ActiveRecord::Base.connection_pool.with_connection do
      raw_json = JSON.parse(raw_post)
      state_json = raw_json["state"]
      bug_json = raw_json.except("state")
      bug = Bug.new(bug_json)
      state = State.new(state_json)
      bug.state = state
      state.bug = bug
      bug.save!
      puts bug
    end
    ack! # we need to let queue know that message was received
  end
end
