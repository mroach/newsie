defmodule Newsie.Providers.CurrentsApiTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.Article
  alias Newsie.Providers.CurrentsApi

  defp json_from_sample(file_name) do
    File.read!("test/samples/currents_api/#{file_name}.json")
    |> Jason.decode!()
    |> Tesla.Mock.json()
  end

  setup do
    mock(fn
      %{method: :get, url: "https://api.currentsapi.services/v1/latest-news"} ->
        json_from_sample("latest_news")

      %{method: :get, url: "https://api.currentsapi.services/v1/available/" <> what} ->
        json_from_sample(what)
    end)

    :ok
  end

  doctest CurrentsApi

  describe "latest_news/1" do
    test "news in english" do
      assert {:ok, articles} = CurrentsApi.latest_news("en")

      assert %Article{
               title: "US House speaker Nancy Pelosi backs congressional legislation on Hong Kong",
               url: "https://www.scmp.com/news/china/politics/article/3027994/us-house-speaker-nancy-pelosi-backs-congressional-legislation",
               author: "Robert Delaney",
               image_url: nil,
               language: :en
             } = Enum.at(articles, 0)

      assert %Article{
               title: "Hong Kong hotel workers go on unpaid leave as tourists shun city",
               url: "https://sg.finance.yahoo.com/news/hong-kong-hotel-workers-go-on-unpaid-leave-as-tourists-shun-city-073722827.html",
               author: "Bloomberg",
               image_url: "https://s.yimg.com/" <> _
             } = Enum.at(articles, 2)
    end
  end

  test "get_supported_categories/0" do
    assert {:ok, cats} = CurrentsApi.get_supported_categories()
    assert Enum.member?(cats, "entertainment")
  end

  test "get_supported_languages" do
    assert {:ok, langs} = CurrentsApi.get_supported_languages()
    assert Enum.member?(langs, "en")
  end

  test "get_supported_regions/0" do
    assert {:ok, regions} = CurrentsApi.get_supported_regions()
    assert Map.has_key?(regions, "INT")
  end
end
