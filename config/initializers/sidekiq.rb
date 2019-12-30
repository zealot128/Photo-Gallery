require 'sidekiq/web'

if Rails.env.production?
  Sidekiq::Logging.logger = Rails.logger
end
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
if Rails.env.production?
  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest('test')) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest('1t5a#'))
  end
end
