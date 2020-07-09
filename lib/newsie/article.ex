defmodule Newsie.Article do
  @moduledoc """
  A news article
  """

  @type t :: %__MODULE__{
          author: String.t() | nil,
          title: String.t(),
          description: String.t() | nil,
          url: String.t(),
          image_url: String.t() | nil,
          date: DateTime.t() | nil,
          content: String.t(),
          structured_content: String.t() | nil,
          source_name: String.t() | nil,
          language: Newsie.Languages.code2() | nil
        }

  defstruct [
    :author,
    :title,
    :description,
    :url,
    :image_url,
    :date,
    :content,
    :structured_content,
    :source_name,
    :language
  ]
end
