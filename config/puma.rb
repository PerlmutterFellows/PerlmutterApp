# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

perlmutter_box = TTY::Box.frame(width: 50, height: 14, align: :center, padding: 2, title: {top_left: "Perlmutter App", bottom_right: "Perlmutter App"}, style: {fg: :blue, bg: :black, border: {fg: :blue, bg: :black}}) do
  "Organization: #{I18n.t('global.organization_name')}\nEmail: #{ENV['GMAIL_USERNAME']}\nTwilio SID: #{ENV['account_sid']}\nTwilio Auth Token: #{ENV['auth_token']}\nTwilio Phone: #{ENV['phone_number']}\nTwilio Phone SID: #{ENV['sid']}\n"
end
puts(perlmutter_box)

if Rails.env.development?
  require 'ngrok/tunnel'
  can_run_ngrok = true
  begin
    Ngrok::Tunnel.start(port: 3000)
  rescue StandardError => e
    can_run_ngrok = false
  end
  if can_run_ngrok && Ngrok::Tunnel.status == :running
    url = Ngrok::Tunnel.ngrok_url_https
    default_url_options = {host: url}
    Rails.application.config.action_controller.asset_host = url
    Rails.application.config.action_mailer.asset_host = url
    Rails.application.routes.default_url_options = default_url_options
    Rails.application.config.action_mailer.default_url_options = default_url_options
    sms_url, call_url = TwilioHandler.new.set_dev_callbacks(url)
    ngrox_box = TTY::Box.frame(width: 50, height: 14, align: :center, padding: 2, title: {top_left: "NGROK", bottom_right: "NGROK"}, style: {fg: :green, bg: :black, border: {fg: :green, bg: :black}}) do
      "STATUS: #{Ngrok::Tunnel.status}\nPORT: #{Ngrok::Tunnel.port}\nHTTP: #{Ngrok::Tunnel.ngrok_url}\nHTTPS: #{Ngrok::Tunnel.ngrok_url_https}\nText Callback: #{sms_url}\nVoice Callback: #{call_url}\n"
    end
  else
    ngrox_box = TTY::Box.frame(width: 50, height: 6, align: :center, padding: 1, title: {top_left: "NGROK", bottom_right: "NGROK"}, style: {fg: :red, bg: :black, border: {fg: :red, bg: :black}}) do
      "Failed to start ;(\nPlease ensure NGROK is configured in PATH.\n"
    end
  end
  puts(ngrox_box)
end
