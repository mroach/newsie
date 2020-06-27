defmodule Newsie.Providers.Newsriver do
  @moduledoc """
  Client for [Newsriver]

  ## Configuration

  Requires `:api_key` to use.

  See `Newsie.ProviderConfig` for documentation on how to configure providers.

  [Newsriver]: https://newsriver.io/
  """

  alias Newsie.Article

  @spec config :: keyword
  def config do
    Newsie.ProviderConfig.get_provider_config(__MODULE__)
  end

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
    query = [query: text, owner: "any"]

    case Tesla.get(client(), "/publisher/search", query: query) do
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

  defp parse_timestamp(<<str::bytes-size(19)>>) do
    parse_timestamp("#{str}Z")
  end

  defp parse_timestamp(str) do
    case DateTime.from_iso8601(str) do
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
      {Tesla.Middleware.BaseUrl, "https://api.newsriver.io/v2/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end
end
