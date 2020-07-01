defmodule Newsie.Provider do
  @moduledoc false

  @doc """
  Query for news articles given the criteria in `Newsie.Query`

  This method is standard across all providers to provide a common interface.

  It is likely that the `Newsie.Query` is not capable of exploiting the full
  query capabilities of the API. If more advanced querying is required, use
  the other access functions in this module.
  """
  @callback query(Newsie.Query.t()) :: {:ok, [Newsie.Article.t()]} | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      alias Newsie.{Article, Query}

      @behaviour Newsie.Provider

      @doc """
      Get current configuration for this provider.

      See `Newsie.Config` for details on how configuration is loaded.
      """
      @spec config() :: keyword()
      def config do
        Newsie.Config.get_provider_config(__MODULE__)
      end
    end
  end
end
