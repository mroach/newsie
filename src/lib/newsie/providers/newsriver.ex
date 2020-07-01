defmodule Newsie.Providers.Newsriver do
  @moduledoc """
  Client for [Newsriver]

  ## Configuration

  Requires `:api_key` to use.

  See `Newsie.Config` for documentation on how to configure providers.

  [Newsriver]: https://newsriver.io/
  """

  use Newsie.Provider

  defp format_time_filter(nil), do: "*"

  defp format_time_filter(%Date{} = date) do
    Date.to_string(date)
  end

  defp format_time_filter(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> format_time_filter()
  end

  defp query_time_filter(nil, nil), do: nil

  defp query_time_filter(start_date, end_date) do
    "discoverDate:[#{format_time_filter(start_date)} TO #{format_time_filter(end_date)}]"
  end

  def render_query(%Query{} = query) do
    extra_filters = [
      query_time_filter(query.start_date, query.end_date)
    ]

    query
    |> Query.criteria()
    |> Enum.map(fn
      {:country, value} ->
        code = value |> to_string() |> String.upcase()
        ~s[website.countryCode:"#{code}"]

      {:language, value} ->
        "language:#{value}"

      {_, _} ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.concat([extra_filters])
    |> Enum.join(" AND ")
  end

  @impl true
  def query(%Query{} = query) do
    options = [limit: Map.get(query, :limit, 10)]

    query
    |> render_query()
    |> search(options)
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
      url: data["url"],
      image_url: find_image(data["elements"]),
      date: parse_timestamp(data["publishDate"] || data["discoverDate"]),
      content: data["text"],
      structured_content: data["structuredText"],
      language: Newsie.Languages.parse_code(data["language"])
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
