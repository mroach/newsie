defmodule Newsie.Providers.WebhoseTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.{Article, Providers.Webhose}

  setup do
    mock(fn
      %{method: :get, url: "https://webhose.io/filterWebContent" <> _} ->
        File.read!("test/samples/webhose/us_news.json")
        |> Jason.decode!()
        |> json()
    end)

    :ok
  end

  describe "search/2" do
    test "searching for english news" do
      assert {:ok, articles} = Webhose.search("site_type:news language:english")

      assert %Article{
               title: "FAA finalizes inspection directive on Boeing 737 MAX planes",
               author: "msn.com",
               date: ~U[2020-06-24T14:23:00.000Z],
               content: "The Federal Aviation Administration (FAA) " <> _,
               url: "https://finance.yahoo.com/news/faa-finalizes-inspection-directive-boeing-142315842.html",
               image_url: "https://s.yimg.com/uu/api/res/" <> _,
               language: "english"
             } = Enum.at(articles, 0)
    end
  end
end
