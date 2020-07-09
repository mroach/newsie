defmodule Newsie.Provider do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Newsie.Article

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
