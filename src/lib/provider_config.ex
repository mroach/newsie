defmodule Newsie.ProviderConfig do
  @env_prefix "NEWSIE_"

  @moduledoc """
  Get provider configuration from app config and ENV

  Configuration for a provider can be set with app config or with environment
  variables that follow the naming convention. Environment variables always
  take precedence application config.

  ## Environment variable naming

  Given the application config:

  ```elixir
  config :newsie, Newsie.Providers.MyNewsProvider, api_key: "asdqwe123"
  ```

  If you wanted to override that with an environment variable, it would be:

  ```
  #{@env_prefix}MY_NEWS_PROVIDER_API_KEY="updated_key"
  ```

  The provider name and parameter name are snake-cased and prefixed with
  `#{@env_prefix}` thus taking on the format:

  `NEWSIE_<provider_name>_<param_name>`
  """

  @spec get_provider_config(atom) :: keyword
  def get_provider_config(provider) do
    app_config = provider_app_config(provider)
    env_config = provider_env_vars(provider)

    Keyword.merge(app_config, env_config) |> List.keysort(0)
  end

  @doc """
  Get configuration from application config.

  Given the app config:

  ```elixir
  config :newsie, Newsie.Providers.DocProvider, api_key: "mykey"
  ```

  Fetching the config for the provider:

  ```
  Newsie.ProviderConfig.provider_app_config(Newsie.Providers.DocProvider)
  [api_key: "mykey"]
  ```
  """
  @spec provider_app_config(atom()) :: keyword()
  def provider_app_config(provider) when is_atom(provider) do
    Application.get_env(:newsie, provider, []) |> List.keysort(0)
  end

  @doc """
  Get configuration from ENV vars for the given provider.

  Prefixes are stripped and only the parameter names are returned as values.

  ### Example
      iex> System.put_env("NEWSIE_DOC_PROVIDER_API_KEY", "mykey")
      ...> Newsie.ProviderConfig.provider_env_vars("DocProvider")
      [api_key: "mykey"]
  """
  @spec provider_env_vars(atom() | binary()) :: keyword()
  def provider_env_vars(provider_name) do
    prefix = @env_prefix <> normalize_provider_name(provider_name)
    slice_len = String.length(prefix) + 1

    System.get_env()
    |> Enum.filter(fn {k, _} -> String.starts_with?(k, prefix) end)
    |> Enum.map(fn {key, value} ->
      key =
        key
        |> String.slice(slice_len..-1)
        |> String.downcase()
        |> String.to_atom()

      {key, value}
    end)
    |> List.keysort(0)
  end

  defp normalize_provider_name(mod) when is_atom(mod) do
    mod
    |> Module.split()
    |> Enum.at(-1)
    |> normalize_provider_name()
  end

  defp normalize_provider_name(provider_name) when is_binary(provider_name) do
    provider_name
    |> Macro.underscore()
    |> String.upcase()
  end
end
