defmodule Newsie.Providers.CurrentsApi do
  @moduledoc """
  Client for [Currents API]

  ## Configuration

  Requires `:api_key` to use.

  See `Newsie.ProviderConfig` for documentation on how to configure providers.

  [Currents API]: https://www.currentsapi.services
  """

  alias Newsie.Article

  @spec config :: keyword
  def config do
    Newsie.ProviderConfig.get_provider_config(__MODULE__)
  end

  @doc """
  Search for news articles

  ### Search parameters

  * `language` (ISO-639-2 code)
  * `keywords`
  * `country` (ISO-3166 code)
  * `category` (see below)
  * `start_date (ISO-8601 timestamp)
  * `end_date` (ISO-8601 timestamp)

  #### Category

  * "regional"
  * "technology"
  * "lifestyle"
  * "business"
  * "general"
  * "programming"
  * "science"
  * "entertainment"
  * "world"
  * "sports"
  * "finance"
  * "academia"
  * "politics"
  * "health"
  * "opinion"
  * "food"
  * "game"

  ### Usage

  ```elixir
  Newsie.Providers.CurrentsApi.search(language: :en, country: :us, category: "business")
  ```
  """
  @spec search(keyword()) :: {:error, any()} | {:ok, [Article.t()]}
  def search(filters) do
    get_articles("/search", filters)
  end

  @doc """
  Get latest news for the given language
  """
  @spec latest_news(String.t()) :: {:error, any()} | {:ok, [Article.t()]}
  def latest_news(language \\ "en") do
    get_articles("/latest-news", language: language)
  end

  defp get_articles(path, query) do
    case Tesla.get(client(), path, query: query) do
      {:ok, %{status: 200, body: body}} ->
        articles = Enum.map(body["news"], &parse_article/1)

        {:ok, articles}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  defp parse_article(data) do
    %Article{
      author: data["author"],
      title: data["title"],
      description: data["description"],
      url: data["url"],
      image_url: find_image(data["image"]),
      date: parse_timestamp(data["published"])
    }
  end

  defp find_image("https://" <> _ = url), do: url
  defp find_image("http://" <> _ = url), do: url
  defp find_image(_), do: nil

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(str) do
    # The timestamps in the API have a space before the UTC offset which is
    # not valid for parsing with DateTime.from_iso8601/1, so remove the space.
    str
    |> String.replace(~r/[ ]\+/, "+")
    |> DateTime.from_iso8601()
    |> case do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp client do
    headers = [
      {"authorization", Keyword.fetch!(config(), :api_key)},
      {"user-agent", Newsie.user_agent()}
    ]

    middleware = [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://api.currentsapi.services/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end
end
