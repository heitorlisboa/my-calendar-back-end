# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_calendar,
  ecto_repos: [MyCalendar.Repo]

# Configures the endpoint
config :my_calendar, MyCalendarWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MyCalendarWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MyCalendar.PubSub,
  live_view: [signing_salt: "XvRZuZmS"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Guardian JWTs duration
config :my_calendar, MyCalendar.Guardian,
  token_ttl: %{
    "access" => {15, :minutes},
    "refresh" => {1, :week}
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import_config "config.secret.exs"
