# Newsie

![Tests](https://github.com/mroach/newsie/workflows/Tests/badge.svg)
![Linter](https://github.com/mroach/newsie/workflows/Linter/badge.svg)

Newsie is a library for accessing APIs that provide news articles.

Installation
------------

Newsie is available on [hex.pm](https://hex.pm/packages/newsie).

You can either add it as a dependency in your `mix.exs`.

To add it to a mix project, just add a line like this in your deps function in mix.exs:

```elixir
defp deps do
  [
    {:newsie, "~> 0.1.0"}
  ]
end
```


Providers
---------

Support for the following providers is built into Newsie:

* [Currents API](https://www.currentsapi.services/en)
* [News API](https://newsapi.org/)
* [Newsriver](https://newsriver.io/)

Configuration
-------------

News APIs require authentication, usually with a simple API key/token.
Check the documentation for each provider and the configuration provider `Newsie.Config`.

Configuration can be set with Elixir application config or with environment variables.

For example if you're configuring the [NewsApi](`Newsie.Providers.NewsApi`) provider which requires an `api_key`.


### App config

```elixir
config :newsie, Newsie.Providers.NewsApi, api_key: "my_api_key"
```

### Environment variable

The format of the environment variable is `NEWSIE_` followed by the provider name and parameter name snake-cased. `NEWSIE_<provider>_<param>`.

```
NEWSIE_NEWS_API_API_KEY=my_api_key
```


Usage
-----

Since each provider has different capabilities and ways of fetching news,
there's currently no unified or standard interface to querying in a provider-agnostic way. Check the documentation for each provider to see how to use them.

* `Newsie.Providers.CurrentsApi`
* `Newsie.Providers.NewsApi`
* `Newsie.Providers.Newsriver`
