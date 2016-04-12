require "lincoln_logger"
require "better_sqs/configuration"
require "better_sqs/client"
require "better_sqs/message"
require "better_sqs/queue"
module BetterSqs
  class << self
    # Allows the user to set configuration options
    #  by yielding the configuration block
    #
    # @param opts [Hash] an optional hash of options, supported options are `reset: true`
    # @param block [Block] an optional configuration block
    # @return [Configuration] the current configuration object
    def configure(opts = {}, &_block)
      @configuration = nil if opts.key?(:reset) && opts[:reset]
      yield(configuration) if block_given?

      configuration.configure_aws
      configuration
    end

    # Returns the singleton class's configuration object
    #
    # @return [Configuration] the current configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    def configured?
      !@configuration.nil?
    end

    def logger
      LincolnLogger.logger
    end
  end
end
