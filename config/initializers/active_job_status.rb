ActiveJobStatus.store = ActiveSupport::Cache::RedisStore.new @options = Rails.application.config_for(:redis)
