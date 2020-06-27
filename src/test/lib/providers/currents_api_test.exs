defmodule Newsie.Providers.CurrentsApiTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.Article
  alias Newsie.Providers.CurrentsApi

  setup do
    mock(fn
      %{method: :get, url: "https://api.currentsapi.services/v1/latest-news"} ->
        File.read!("test/samples/currents_api/latest_news.json")
        |> Jason.decode!()
        |> json()
    end)

    :ok
  end

  doctest CurrentsApi

  @tag capture_log: true
  describe "latest_news/1" do
    test "news in english" do
      assert {:ok, articles} = CurrentsApi.latest_news("en")

      assert %Article{
               title: "US House speaker Nancy Pelosi backs congressional legislation on Hong Kong",
               url: "https://www.scmp.com/news/china/politics/article/3027994/us-house-speaker-nancy-pelosi-backs-congressional-legislation",
               author: "Robert Delaney",
               image_url: nil
             } = Enum.at(articles, 0)

      assert %Article{
               title: "Hong Kong hotel workers go on unpaid leave as tourists shun city",
               url: "https://sg.finance.yahoo.com/news/hong-kong-hotel-workers-go-on-unpaid-leave-as-tourists-shun-city-073722827.html",
               author: "Bloomberg",
               image_url: "https://s.yimg.com/" <> _
             } = Enum.at(articles, 2)
    end
  end
end
