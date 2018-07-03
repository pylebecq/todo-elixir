# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :worker, WorkerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rP9IffF/vhnVl72nqErr+f7mnDaJibMFXH+FFOzZ/wSBXdV5OUQyL51VqXfSfB7j",
  render_errors: [view: WorkerWeb.ErrorView, accepts: ~w(html json)],
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
