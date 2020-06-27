defmodule Newsie.Providers.CurrentsApi do
  @api_key_env_var "NEWSIE_CURRENTS_API_KEY"

  @moduledoc """
  Client for [Currents API]

  Requires an API key to use.

  ### Configuration

  Setting the API key can be done with the environment variable `#{@api_key_env_var}`
  or with application configuration:

  ```elixir
  config :newsie, Newsie.Providers.CurrentsApi, api_key: "my_api_key"
  ```

  [Currents API]: https://www.currentsapi.services
  """

  alias Newsie.Article

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

  defp get_articles(path, query_params) do
    query = URI.encode_query(query_params)

    case Tesla.get(client(), "#{path}?#{query}") do
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
    middleware = [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://api.currentsapi.services/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Timeout, [timeout: api_timeout()]},
      {Tesla.Middleware.Headers, [{"authorization", api_key()}]}
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

  defp api_timeout do
    Keyword.get(module_config(), :timeout, 2_000)
  end
end
