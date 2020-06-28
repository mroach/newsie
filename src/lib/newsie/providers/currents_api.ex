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

  * `type` (see below)
  * `category` (see below)
  * `language` (ISO-639-2 code)
  * `keywords`
  * `country` (ISO-3166 code)
  * `start_date` (ISO-8601 timestamp)
  * `end_date` (ISO-8601 timestamp)

  #### Type

  The Currents API provides differnt kinds of content; not just new.
  The `type` filter controls the kind of content you want.

  * 1 = news (default)
  * 2 = article
  * 3 = discussion content

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
    # type: 1 = news, 2 = article, 3 = discussion content
    default_filters = [type: 1]
    filters = Keyword.merge(default_filters, filters)

    get_articles("/search", filters)
  end

  @doc """
  Get latest news for the given language
  """
  @spec latest_news(String.t()) :: {:error, any()} | {:ok, [Article.t()]}
  def latest_news(language \\ "en") do
    get_articles("/latest-news", language: language)
  end

  @doc """
  Get a list of supported languages.
  """
  @spec get_supported_languages :: {:error, any()} | {:ok, [String.t()]}
  def get_supported_languages do
    client()
    |> Tesla.get("available/languages")
    |> handle_success(fn resp -> Map.values(resp.body["languages"]) end)
  end

  @doc """
  Get a list of supported regions.

  These are mostly ISO country codes, but some are regions like 'ASIA' and 'INT'
  """
  @spec get_supported_regions :: {:error, any()} | {:ok, %{String.t() => String.t()}}
  def get_supported_regions do
    client()
    |> Tesla.get("available/regions")
    |> handle_success(fn resp ->
      Map.new(resp.body["regions"], fn {k, v} -> {v, k} end)
    end)
  end

  @doc "Get a list of supported categories"
  @spec get_supported_categories :: {:error, any} | {:ok, [String.t()]}
  def get_supported_categories do
    client()
    |> Tesla.get("available/categories")
    |> handle_success(fn resp -> resp.body["categories"] end)
  end

  defp handle_success({:ok, %{status: 200} = resp}, fun) when is_function(fun, 1) do
    {:ok, fun.(resp)}
  end

  defp handle_success({:ok, response}, _), do: {:error, response}
  defp handle_success({:error, response}, _), do: {:error, response}

  defp get_articles(path, query) do
    client()
    |> Tesla.get(path, query: query)
    |> handle_success(fn resp -> Enum.map(resp.body["news"], &parse_article/1) end)
  end

  defp parse_article(data) do
    %Article{
      author: data["author"],
      title: data["title"],
      description: data["description"],
      url: data["url"],
      image_url: find_image(data["image"]),
      date: parse_timestamp(data["published"]),
      language: Newsie.Languages.parse_code(data["language"])
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
