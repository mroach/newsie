defmodule Newsie.Providers.NewsriverTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Newsie.Providers.Newsriver

  doctest Newsriver

  setup do
    mock(fn
      %{
        method: :get,
        url: "https://api.newsriver.io/v2/search?query=website.domainName%3Acnn.com"
      } ->
        File.read!("test/samples/newsriver/cnn.json")
        |> Jason.decode!()
        |> json()
    end)

    :ok
  end

  test "fetching CNN articles" do
    assert {:ok, articles} = Newsriver.search("website.domainName:cnn.com")

    assert %Newsie.Article{} = Enum.at(articles, 0)
  end
end
