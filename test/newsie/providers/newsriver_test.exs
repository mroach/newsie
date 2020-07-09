defmodule Newsie.Providers.NewsriverTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.{Article, Providers.Newsriver}

  doctest Newsriver

  setup do
    mock(fn
      %{method: :get, url: "https://api.newsriver.io/v2/search?query=website.domainName%3Acnn.com"} ->
        File.read!("test/samples/newsriver/cnn.json")
        |> Jason.decode!()
        |> json()
    end)

    :ok
  end

  test "fetching CNN articles" do
    assert {:ok, articles} = Newsriver.search("website.domainName:cnn.com")

    {:ok, date} = DateTime.from_naive(~N[2014-09-18T00:00:00], "Etc/UTC")

    assert %Article{
             title: "Chris Christie accuses 'Bridgegate' panel of playing politics",
             author: nil,
             source_name: "CNN - Cable News Network",
             description: nil,
             url: "http://politicalticker.blogs.cnn.com/2014/09/18/chris-christie-accuses-bridgegate-panel-of-playing-politics/",
             image_url: "http://i2.cdn.turner.com/cnn" <> _,
             date: ^date,
             content: "New Jersey Gov. Chris Christie" <> _,
             structured_content: "<div> \n <p>" <> _,
             language: :en
           } = Enum.at(articles, 0)
  end
end
