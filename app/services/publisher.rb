# https://monterail.com/blog/2014/event-sourcing-on-rails-with-rabbitmq
# FIXME: Implement in a cleaner way
class Publisher
  # In order to publish message we need a exchange name.
  # Note that RabbitMQ does not care about the payload -
  # we will be using JSON-encoded strings
  def self.publish(message = {})
    @@connection ||= $bunny.tap do |c|
      c.start
    end
    @@channel ||= @@connection.create_channel
    @@fanout ||= @@channel.fanout("instaapi.bugs")
    @@queue ||= @@channel.queue("instaapi.bugs", durable: true).tap do |q|
      q.bind("instaapi.bugs")
    end
    # and simply publish message
    @@fanout.publish(message)
  end
end
