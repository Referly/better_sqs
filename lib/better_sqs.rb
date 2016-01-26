require "lincoln_logger"
require "better_sqs/configuration"
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

      configuration
    end

    # Returns the singleton class's configuration object
    #
    # @return [Configuration] the current configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    def logger
      LincolnLogger.logger
    end
  end
end
