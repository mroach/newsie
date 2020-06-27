defmodule Newsie.Providers.Webhose do
  @api_key_env_var "NEWSIE_WEBHOSE_KEY"

  @moduledoc """
  Client for [Webhose]

  Requires an API key to use.

  ### Configuration

  Setting the API key can be done with the environment variable `#{@api_key_env_var}`
  or with application configuration:

  ```elixir
  config :newsie, Newsie.Providers.Webhose, api_key: "my_api_key"
  ```

  [Webhose]: https://docs.webhose.io/docs
  """

  alias Newsie.Article

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
      content: data["text"]
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
      {"token", api_key()}
    ]

    middleware = [
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://webhose.io"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Query, default_query}
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
