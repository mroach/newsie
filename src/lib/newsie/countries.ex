defmodule Newsie.Countries do
  @type code2 :: atom()
  @type name :: String.t()

  @iso_3166_codes for(
                    line <- File.stream!("data/iso-3166.tab"),
                    line = String.trim(line),
                    String.length(line) > 0,
                    String.first(line) != "#",
                    row = String.split(line, "\t"),
                    code = Enum.at(row, 0),
                    code = code |> String.downcase() |> String.to_atom(),
                    name = Enum.at(row, 1),
                    do: {code, name}
                  )
                  |> Map.new()

  @name_to_code @iso_3166_codes |> Map.new(fn {code, name} -> {String.downcase(name), code} end)

  @moduledoc """
  Helper for ISO-3166 country codes

  ## Current codes and English names

  ```
  #{
    @iso_3166_codes
    |> Enum.to_list()
    |> List.keysort(0)
    |> inspect(pretty: true, limit: :infinity)
  }
  ```
  """

  @doc "Get a map of ISO-3166 country codes with English names"
  @spec iso_3166 :: %{code2() => name()}
  def iso_3166, do: @iso_3166_codes

  @doc """
  Convert an ISO-3166 country code to its English name

  ### Examples
      iex> Newsie.Countries.code_to_name(:se)
      "Sweden"
  """
  @spec code_to_name(code2() | binary()) :: name() | nil
  def code_to_name(code) when is_binary(code) do
    code
    |> parse_code()
    |> code_to_name()
  end

  def code_to_name(code) when is_atom(code) do
    Map.get(@iso_3166_codes, code)
  end

  @doc """
  Convert an English country name to its ISO-3166 code

  ### Examples
      iex> Newsie.Countries.name_to_code("France")
      :fr

      iex> Newsie.Countries.name_to_code("australia")
      :au

      iex> Newsie.Countries.name_to_code("invalid")
      nil
  """
  @spec name_to_code(binary()) :: code2() | nil
  def name_to_code(name) do
    Map.get(@name_to_code, String.downcase(name))
  end

  @doc """
  Validate an ISO-3166 country code from a string or atom.

  ### Examples
      iex> Newsie.Countries.parse_code(:au)
      :au

      iex> Newsie.Countries.parse_code("DE")
      :de

      iex> Newsie.Countries.parse_code("france")
      nil
  """
  @spec parse_code(code2() | binary()) :: code2() | nil
  def parse_code(code) when is_atom(code) do
    if Map.has_key?(@iso_3166_codes, code), do: code, else: nil
  end

  def parse_code(code) when is_binary(code) do
    code
    |> String.downcase()
    |> String.to_existing_atom()
    |> parse_code()
  rescue
    ArgumentError -> nil
  end
end
