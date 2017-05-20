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
      bug_json = JSON.parse(raw_post)
      bug = Bug.new(bug_json)
      bug.save!
      puts bug_json
    end
    ack! # we need to let queue know that message was received
  end
end
