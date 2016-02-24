module BetterSqs
  # Provides configuration management for the BetterSqs gem
  class Configuration
    attr_accessor :queue_name,
                  :region,
                  :sqs_message_deferral_seconds,
                  :aws_access_key_id,
                  :aws_secret_access_key

    def initialize
      @sqs_message_deferral_seconds = 60
      @aws_access_key_id      = ENV["AWS_ACCESS_KEY_ID"]
      @aws_secret_access_key  = ENV["AWS_SECRET_ACCESS_KEY"]
      @region                 = ENV["AWS_REGION"] || "us-east-1"
    end

    def configure_aws
      return configure_region_only unless aws_secret_access_key && aws_access_key_id
      Aws.config.update(
        region:      region,
        credentials: Aws::Credentials.new(aws_access_key_id, aws_secret_access_key),
      )
    end

    private

    def configure_region_only
      Aws.config.update(region: region)
    end
  end
end
