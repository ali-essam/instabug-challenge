$redis = Redis::Namespace.new("instaapi", :redis => Redis.new(:host => ENV["REDIS_HOST"]))
