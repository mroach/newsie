defmodule Newsie.Providers.NewsApiTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.Providers.NewsApi

  doctest NewsApi

  setup do
    mock(fn
      %{method: :get, url: "http://newsapi.org/v2/sources?language=en"} ->
        File.read!("test/samples/news_api/sources_en.json")
        |> Jason.decode!()
        |> json()
    end)

    :ok
  end

  describe "sources/1" do
    test "fetching English sources" do
      assert {:ok, sources} = NewsApi.list_sources(language: :en)
      assert %{"name" => "ABC News"} = Enum.at(sources, 0)
    end
  end
end
