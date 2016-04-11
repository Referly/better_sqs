require "active_support/inflector"
module BetterSqs
  class Queue
    attr_accessor :better_client,
                  :queue_name

    def initialize(better_client, queue_name)
      @better_client = better_client
      @queue_name = queue_name
    end

    # Push a message onto a queue
    #
    # @param message_body [String] the message as it will be pushed onto the queue, no serialization occurs as
    #  part of this method. You need to encode or serialize your object to a string before sending it to this method
    # @return [Types::SendMessageResult] the sent message object returned from s3
    def push(message_body)
      better_client.push queue_name, message_body
    end

    # Reserve a message from the specified queue
    #
    # @return [Messages::Sqs, NilClass] the message retrieved from the queue
    def reserve
      better_client.reserve queue_name
    end

    QUEUE_ATTRIBUTES = [
        :approximate_number_of_messages,
        :approximate_number_of_messages_not_visible,
        :visibility_timeout,
        :created_timestamp,
        :last_modified_timestamp,
        :policy,
        :maximum_message_size,
        :message_retention_period,
        :queue_arn,
        :approximate_number_of_messages_delayed,
        :delay_seconds,
        :receive_message_wait_time_seconds,
        :redrive_policy
    ]
    QUEUE_ATTRIBUTES.each do |queue_attribute|
      define_method queue_attribute do
        resp = better_client.sqs.get_queue_attributes queue_url: better_client.url_for_queue(queue_name),
                                               attribute_names: [queue_attribute.to_s.camelize]
        resp.attributes[queue_attribute.to_s.camelize]
      end
    end
  end
end