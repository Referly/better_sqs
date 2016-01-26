module BetterSqs
  # Provides configuration management for the BetterSqs gem
  class Configuration
    attr_accessor :queue_name,
                  :region
  end
end
