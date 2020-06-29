defmodule Newsie.Query do
  @moduledoc "Provider-agnostic structured query"

  alias __MODULE__
  alias Newsie.{Countries, Languages}

  @type t :: %__MODULE__{
          language: Languages.code2(),
          country: Countries.code2(),
          start_date: DateTime.t(),
          end_date: DateTime.t(),
          limit: non_neg_integer()
        }

  defstruct [
    :language,
    :country,
    :start_date,
    :end_date,
    :limit
  ]

  @doc """
  Build a query from a `Map` or `Keyword` of params.

  Parameters are parsed and converted as necessary to create a proper Query.

  ### Example
      <!-- Can't use the ~U[] sigil until dropping support for Elixir < 1.9 -->

      iex> Newsie.Query.new(language: "EN", country: "Australia", end_date: ~D[2020-06-15])
      %Newsie.Query{
        language: :en,
        country: :au,
        start_date: nil,
        end_date: %DateTime{
          year: 2020, month: 06, day: 15,
          hour: 0, minute: 0, second: 0,
          time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0
        }
      }

      iex> Newsie.Query.new(language: "German", country: "CH", start_date: ~D[2020-06-15])
      %Newsie.Query{
        language: :de,
        country: :ch,
        start_date: %DateTime{
          year: 2020, month: 06, day: 15,
          hour: 0, minute: 0, second: 0,
          time_zone: "Etc/UTC", zone_abbr: "UTC", utc_offset: 0, std_offset: 0
        }
      }
  """
  @spec new(keyword() | map()) :: t()
  def new(params) do
    Enum.reduce(params, %Query{}, fn {param, value}, query ->
      apply(__MODULE__, :"put_#{param}", [query, value])
    end)
  end

  @doc """
  Get query criteria that are present (i.e. not `nil`) as a `Map`

  ### Example
      iex> query = %Newsie.Query{country: :jp, language: nil}
      ...> Newsie.Query.criteria(query)
      %{country: :jp}
  """
  @spec criteria(t()) :: map()
  def criteria(%Query{} = query) do
    Map.new(for {k, v} <- Map.from_struct(query), v != nil, do: {k, v})
  end

  @doc """
  Set the `start_date` on the query.

  Accepts a `Date` or `DateTime`.
  """
  @spec put_start_date(t(), Date.t() | DateTime.t()) :: t()
  def put_start_date(%Query{} = q, %Date{} = date) do
    put_start_date(q, date_to_datetime(date))
  end

  def put_start_date(%Query{} = q, %DateTime{} = dt) do
    Map.put(q, :start_date, dt)
  end

  @doc """
  Set the `end_date` on the query.

  Accepts a `Date` or `DateTime`.
  """
  @spec put_end_date(t(), Date.t() | DateTime.t()) :: t()
  def put_end_date(%Query{} = q, %Date{} = date) do
    put_end_date(q, date_to_datetime(date))
  end

  def put_end_date(%Query{} = q, %DateTime{} = dt) do
    Map.put(q, :end_date, dt)
  end

  @doc """
  Set the `country` on the query.

  Accepts a country code atom, country code string, or country name string.

  ### Example
      iex> Newsie.Query.put_country(%Query{}, "Singapore")
      %Newsie.Query{country: :sg}

      iex> Newsie.Query.put_country(%Query{}, "AU")
      %Newsie.Query{country: :au}

      iex> Newsie.Query.put_country(%Query{}, :ch)
      %Newsie.Query{country: :ch}
  """
  @spec put_country(t(), Countries.code2() | Countries.name()) :: t()
  def put_country(%Query{} = q, code) when is_atom(code) do
    Map.put(q, :country, Countries.parse_code(code))
  end

  def put_country(%Query{} = q, <<code::binary-size(2)>>) do
    Map.put(q, :country, Countries.parse_code(code))
  end

  def put_country(%Query{} = q, name) when is_binary(name) do
    put_country(q, Countries.name_to_code(name))
  end

  @doc """
  Set the `language` on the query.

  Accepts a language code atom, language code string, or language name string.

  ### Example
      iex> Newsie.Query.put_language(%Query{}, "Japanese")
      %Newsie.Query{language: :ja}

      iex> Newsie.Query.put_language(%Query{}, "EN")
      %Newsie.Query{language: :en}

      iex> Newsie.Query.put_language(%Query{}, :de)
      %Newsie.Query{language: :de}
  """
  @spec put_language(t(), Languages.code2() | Languages.name()) :: t()
  def put_language(%Query{} = q, code) when is_atom(code) do
    Map.put(q, :language, Languages.parse_code(code))
  end

  def put_language(%Query{} = q, <<code::binary-size(2)>>) do
    Map.put(q, :language, Languages.parse_code(code))
  end

  def put_language(%Query{} = q, name) when is_binary(name) do
    put_language(q, Languages.name_to_code(name))
  end

  @doc """
  Set the `limit` on the query.

  Only accepts a non-negative integer.
  """
  @spec put_limit(t(), non_neg_integer()) :: t()
  def put_limit(%Query{} = q, limit) when is_integer(limit) and limit >= 0 do
    Map.put(q, :limit, limit)
  end

  defp date_to_datetime(%Date{year: year, month: month, day: day}) do
    %DateTime{
      year: year,
      month: month,
      day: day,
      hour: 0,
      minute: 0,
      second: 0,
      time_zone: "Etc/UTC",
      zone_abbr: "UTC",
      utc_offset: 0,
      std_offset: 0
    }
  end
end
