defmodule Newsie.Providers.NewsApi do
  @moduledoc """
  Client for [News API]

  ## Configuration

  Requires `:api_key` to use.

  See `Newsie.ProviderConfig` for documentation on how to configure providers.

  [News API]: https://newsapi.org/
  """

  alias Newsie.Article

  @spec config :: keyword
  def config do
    Newsie.ProviderConfig.get_provider_config(__MODULE__)
  end

  @spec top_headlines(any) :: {:error, any()} | {:ok, [Article.t()]}
  def top_headlines(query) do
    case Tesla.get(client(), "/top-headlines", query: query) do
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
  def list_sources(query \\ []) do
    case Tesla.get(client(), "/sources", query: query) do
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
      date: parse_timestamp(data["publishedAt"]),
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
    headers = [
      {"x-api-key", Keyword.fetch!(config(), :api_key)},
      {"user-agent", Newsie.user_agent()}
    ]

    middleware = [
      {Tesla.Middleware.BaseUrl, "http://newsapi.org/v2/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end
end
