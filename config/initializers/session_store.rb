# Be sure to restart your server when you modify this file.
if Rails.env.production?
Rails.application.config.session_store :redis_store, {
  servers: [
    {
      host: "localhost",
      port: 6379,
      db: 0,
      password: Rails.application.config_for(:redis)["password"],
      namespace: "session"
    },
  ],
  expire_after: 90.minutes,
  key: "_epigaea_session"
}
else
Rails.application.config.session_store :redis_store
end
