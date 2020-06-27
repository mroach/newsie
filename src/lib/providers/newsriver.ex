defmodule Newsie.Providers.Newsriver do
  @api_key_env_var "NEWSIE_NEWSRIVER_KEY"

  @moduledoc """
  Client for [Newsriver]

  Requires an API key to use.

  ### Configuration

  Setting the API key can be done with the environment variable `#{@api_key_env_var}`
  or with application configuration:

  ```elixir
  config :newsie, Newsie.Providers.Newsriver, api_key: "my_api_key"
  ```

  [Newsriver]: https://newsriver.io/
  """

  alias Newsie.Article

  @doc """
  Search for news articles with a SQL-like query

  ### Usage

  ```elixir
  Newsie.Providers.Newsriver.search("language:EN AND website.domainName:cnn.com", limit: 5)
  ```
  """
  @spec search(any(), keyword()) :: {:error, any()} | {:ok, [Article.t()]}
  def search(query, options \\ []) do
    query =
      options
      |> Keyword.put(:query, query)
      |> URI.encode_query()

    case Tesla.get(client(), "/search?#{query}") do
      {:ok, %{status: 200, body: body}} ->
        articles = Enum.map(body, &parse_article/1)

        {:ok, articles}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  @doc """
  Search the list of news sources provided by this API.

  ### Example

  Newsie.Providers.Newsriver.search_sources("cnn")
  """
  @spec search_sources(String.t()) :: {:error, any} | {:ok, [map()]}
  def search_sources(text) do
    query = URI.encode_query(query: text, owner: "any")

    case Tesla.get(client(), "/publisher/search?#{query}") do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  defp parse_article(data) do
    %Article{
      source_name: Kernel.get_in(data, ["website", "name"]),
      author: nil,
      title: data["title"],
      description: data["description"],
      url: data["url"],
      image_url: find_image(data["elements"]),
      date: parse_timestamp(data["publishDate"] || data["discoverDate"]),
      content: data["text"],
      structured_content: data["structuredText"]
    }
  end

  defp find_image(elements) do
    elements
    |> Enum.find(fn e -> e["type"] == "Image" && e["primary"] == true end)
    |> case do
      nil -> nil
      e -> e["url"]
    end
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
      {"authorization", api_key()},
      {"user-agent", Newsie.user_agent()}
    ]

    middleware = [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://api.newsriver.io/v2/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
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
