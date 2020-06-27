defmodule Newsie.ProviderConfigTest do
  use ExUnit.Case

  alias Newsie.ProviderConfig

  setup_all do
    env_vars = [
      {"NEWSIE_MY_PROVIDER_TIMEOUT", "1000"},
      {"NEWSIE_MY_PROVIDER_API_KEY", "asdqwe123"},
      {"NEWSIE_OTHER_PROVIDER_API_KEY", "key1"},
      {"NEWSIE_FAKE_PROVIDER_API_KEY", "newkey"}
    ]

    System.put_env(env_vars)

    on_exit(fn ->
      for {k, _} <- env_vars, do: System.delete_env(k)
    end)

    {:ok, %{env_vars: env_vars}}
  end

  describe "provider_env_vars/1" do
    test "with no matching env vars" do
      assert [] == ProviderConfig.provider_env_vars("bogus_provider")
    end

    test "finds config for the provider" do
      assert [api_key: "asdqwe123", timeout: "1000"] ==
               ProviderConfig.provider_env_vars("MyProvider")
    end

    test "finds config for another provider" do
      assert [api_key: "key1"] == ProviderConfig.provider_env_vars("other_provider")
    end
  end

  describe "provider_app_config/1" do
    test "with no config present" do
      assert [] = ProviderConfig.provider_app_config(Newsie.Providers.NoSuchProvider)
    end

    test "with config present" do
      assert [api_key: "bogus", timeout: 100] =
               ProviderConfig.provider_app_config(Newsie.Providers.FakeProvider)
    end
  end

  describe "get_provider_config/1" do
    # app config is set in config.exs for a FakeProvider
    test "env vars override app config" do
      assert [timeout: 100, api_key: "newkey"] =
               ProviderConfig.get_provider_config(Newsie.Providers.FakeProvider)
    end
  end
end
