# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :engine,
  ecto_repos: [Engine.Repo]

# Configures the endpoint
config :engine, EngineWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nOwUYHN6Kl+NIKNDbK6VAiNPIIip6LbxbvSjfYbFvded0Tw7N+JsshxCb423pAA8",
  render_errors: [view: EngineWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: :todo_elixir,
           adapter: Phoenix.PubSub.Redis,
           node_name: System.get_env("NODE")]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
