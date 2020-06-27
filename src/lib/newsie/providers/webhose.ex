defmodule Newsie.Providers.Webhose do
  @moduledoc """
  Client for [Webhose]

  ## Configuration

  Requires `:api_key` to use.

  See `Newsie.ProviderConfig` for documentation on how to configure providers.
  ```

  [Webhose]: https://docs.webhose.io/docs
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
  Newsie.Providers.Webhose.search("site_type:news site_category:business", size: 5)
  ```
  """
  @spec search(any(), keyword()) :: {:error, any()} | {:ok, [Article.t()]}
  def search(filters, options \\ []) do
    query = [q: filters] ++ options

    case Tesla.get(client(), "/filterWebContent", query: query) do
      {:ok, %{status: 200, body: body}} ->
        articles = Enum.map(body["posts"], &parse_article/1)

        {:ok, articles}

      {:ok, resp} ->
        {:error, resp}

      {:error, other} ->
        {:error, other}
    end
  end

  defp parse_article(data) do
    thread = data["thread"]

    %Article{
      source_name: thread["site"],
      author: data["author"],
      title: data["title"],
      url: data["url"],
      image_url: thread["main_image"],
      date: parse_timestamp(data["published"]),
      content: data["text"],
      language: Newsie.Languages.name_to_code(data["language"])
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
    default_query = [
      {"format", "json"},
      {"token", Keyword.fetch!(config(), :api_key)}
    ]

    headers = [
      {"user-agent", Newsie.user_agent()}
    ]

    middleware = [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://webhose.io"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Query, default_query},
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end
end
