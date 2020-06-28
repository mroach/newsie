defmodule Newsie.Languages do
  @type code2 :: atom()
  @type name :: String.t()

  # Some langauges are tagged with " (macrolanguage)" or the centuries the
  # entry refers to. Simplify the list with custom language name mappings.
  @custom_mappings %{
    ne: "Nepali",
    sw: "Swahili",
    ms: "Malay",
    or: "Oriya",
    oc: "Occitan",
    to: "Tonga",
    el: "Greek"
  }

  @iso_639_codes for(
                   line <- File.stream!("data/iso-639-3.tab"),
                   Stream.drop(line, 1),
                   row = String.split(line, "\t"),
                   code = Enum.at(row, 3),
                   String.length(code) == 2,
                   code = String.to_atom(code),
                   Enum.at(row, 5) == "L",
                   name = Enum.at(row, 6),
                   name = Map.get(@custom_mappings, code, name),
                   do: {code, name}
                 )
                 |> Map.new()

  @name_to_code @iso_639_codes |> Map.new(fn {code, name} -> {String.downcase(name), code} end)

  @moduledoc """
  Basic provider of ISO-639 language codes and names

  ## Current codes and English names

  ```
  #{
    @iso_639_codes
    |> Enum.to_list()
    |> List.keysort(0)
    |> inspect(pretty: true, limit: :infinity)
  }
  ```
  """

  @doc """
  Get a `Map` of ISO-639 2-letter language codes and their English name.
  """
  @spec iso_639() :: map()
  def iso_639, do: @iso_639_codes

  @doc """
  Get the English name of a language based on its 2-letter language code

  ### Example
      iex> Newsie.Languages.code_to_name(:en)
      "English"

      iex> Newsie.Languages.code_to_name(:ja)
      "Japanese"

      iex> Newsie.Languages.code_to_name(:xx)
      nil
  """
  @spec code_to_name(code2() | binary()) :: String.t() | nil
  def code_to_name(code) when is_binary(code) do
    code
    |> parse_code()
    |> code_to_name()
  end

  def code_to_name(code) when is_atom(code) do
    Map.get(@iso_639_codes, code)
  end

  @doc """
  Convert a language name to ISO code

  ### Example
      iex> Newsie.Languages.name_to_code("french")
      :fr

      iex> Newsie.Languages.name_to_code("English")
      :en

      iex> Newsie.Languages.name_to_code("Klingon")
      nil
  """
  @spec name_to_code(binary()) :: code2() | nil
  def name_to_code(name) do
    Map.get(@name_to_code, String.downcase(name))
  end

  @doc """
  Validate an ISO-639 language code and convert it to the correct atom.

  Invalid language codes will get `nil`

  ### Examples
      iex> Newsie.Languages.parse_code("en")
      :en

      iex> Newsie.Languages.parse_code("DE")
      :de

      iex> Newsie.Languages.parse_code(:ja)
      :ja

      iex> Newsie.Languages.parse_code("jp")
      nil
  """
  @spec parse_code(code2() | binary()) :: code2() | nil
  def parse_code(code) when is_atom(code) do
    if Map.has_key?(@iso_639_codes, code), do: code, else: nil
  end

  def parse_code(code) when is_binary(code) do
    # any valid language code atom will already be defined by the map creation.
    code
    |> String.downcase()
    |> String.to_existing_atom()
    |> parse_code()
  rescue
    ArgumentError -> nil
  end
end
