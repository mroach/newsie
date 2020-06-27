use Mix.Config

if Mix.env() == :test do
  config :logger, :console,
    level: :debug,
    format: "$date $time [$level] $metadata$message\n"

  config :tesla, adapter: Tesla.Mock

  # Debug logging with Tesla is broken and tries to log the JSON structure
  # and this breaks in older Elixir versions. Modern versions warn.
  config :tesla, Tesla.Middleware.Logger, debug: false

  # satisfy requirement for api keys to be set
  config :newsie, Newsie.Providers.NewsApi, api_key: "bogus"
  config :newsie, Newsie.Providers.Newsriver, api_key: "bogus"

  # generate fake config for testing purposes
  config :newsie, Newsie.Providers.FakeProvider, api_key: "bogus", timeout: 100
end
