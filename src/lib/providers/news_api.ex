defmodule Newsie.Providers.NewsApi do
  @api_key_env_var "NEWSIE_NEWS_API_KEY"

  @moduledoc """
  Client for [News API]

  Requires an API key to use.

  ### Configuration

  Setting the API key can be done with the environment variable `#{@api_key_env_var}`
  or with application configuration:

  ```elixir
  config :newsie, Newsie.Providers.NewsApi, api_key: "my_api_key"
  ```

  [News API]: https://newsapi.org/
  """

  alias Newsie.Article

  @spec top_headlines(any) :: {:error, any()} | {:ok, [Article.t()]}
  def top_headlines(filters) do
    query = URI.encode_query(filters)

    case Tesla.get(client(), "/top-headlines?#{query}") do
      {:ok, %{status: 200, body: body}} ->
        articles =
          body
          |> Map.get("articles")
          |> Enum.map(&parse_article/1)

        {:ok, articles}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  @doc """
  Get a list of news sources provided by this API.

  ### Example

  Newsie.Providers.NewsApi.list_sources(country: :gb)

  {:ok, [
    {
      "id": "bbc-news",
      "name": "BBC News",
      "description": "Use BBC News for up-to-the-minute news, breaking news, video, audio and feature stories. BBC News provides trusted World and UK news as well as local and regional perspectives. Also entertainment, business, science, technology and health news.",
      "url": "http://www.bbc.co.uk/news",
      "category": "general",
      "language": "en",
      "country": "gb"
    },
    {
      "id": "business-insider-uk",
      "name": "Business Insider (UK)",
      "description": "Business Insider is a fast-growing business site with deep financial, media, tech, and other industry verticals. Launched in 2007, the site is now the largest business news site on the web.",
      "url": "http://uk.businessinsider.com",
      "category": "business",
      "language": "en",
      "country": "gb"
    }
  ]}
  """
  @spec list_sources :: {:error, any} | {:ok, any}
  def list_sources(filters \\ []) do
    query = URI.encode_query(filters)

    case Tesla.get(client(), "/sources?#{query}") do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body["sources"]}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  defp parse_article(data) do
    %Article{
      source_name: Kernel.get_in(data, ["source", "name"]),
      author: data["author"],
      title: data["title"],
      description: data["description"],
      url: data["url"],
      image_url: data["urlToImage"],
      published_at: parse_timestamp(data["publishedAt"]),
      content: data["content"]
    }
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp client do
    middleware = [
      {Tesla.Middleware.BaseUrl, "http://newsapi.org/v2/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-api-key", api_key()}]}
    ]

    Tesla.client(middleware)
  end

  defp module_config do
    Application.get_env(:newsie, __MODULE__) || []
  end

  defp api_key_from_env do
    System.get_env("#{@api_key_env_var}")
  end

  defp api_key do
    case Keyword.fetch(module_config(), :api_key) do
      {:ok, key} -> key
      :error -> api_key_from_env()
    end
  end
end
