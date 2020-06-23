defmodule Newsie.Article do
  @moduledoc """
  A news article
  """

  @type t :: %__MODULE__{
          author: String.t(),
          title: String.t(),
          description: String.t(),
          url: String.t(),
          image_url: String.t(),
          published_at: DateTime.t(),
          content: String.t(),
          source_name: String.t()
        }

  defstruct [
    :author,
    :title,
    :description,
    :url,
    :image_url,
    :published_at,
    :content,
    :source_name
  ]
end
