defmodule Newsie.Providers.NewsApiTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.{Article, Providers.NewsApi}

  doctest NewsApi

  setup do
    mock(fn
      %{method: :get, url: "http://newsapi.org/v2/sources", query: [language: :en]} ->
        File.read!("test/samples/news_api/sources_en.json")
        |> Jason.decode!()
        |> json()

      %{method: :get, url: "http://newsapi.org/v2/top-headlines"} ->
        File.read!("test/samples/news_api/top_headlines.json")
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

  describe "top_headlines/1" do
    test "fetches top headlines" do
      {:ok, date, 0} = DateTime.from_iso8601("2020-06-27T16:25:09Z")
      assert {:ok, articles} = NewsApi.top_headlines(country: :us)

      assert %Article{
               source_name: "New York Times",
               author: nil,
               title: "Coronavirus Live Updates: Latest News and Analysis - The New York Times",
               description: "China says it has largely contained" <> _,
               url: "https://www.nytimes.com/2020/06/27/" <> _,
               image_url: "https://www.nytimes.com/newsgraphics/" <> _,
               date: ^date,
               content: "The analysis is part" <> _
             } = Enum.at(articles, 0)
    end
  end
end
