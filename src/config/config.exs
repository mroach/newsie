use Mix.Config

if Mix.env() == :test do
  config :logger, :console,
    level: :debug,
    format: "$date $time [$level] $metadata$message\n"

  config :tesla, adapter: Tesla.Mock

  # Debug logging with Tesla is broken and tries to log the JSON structure
  # and this breaks in older Elixir versions. Modern versions warn.
  config :tesla, Tesla.Middleware.Logger, debug: false
end
