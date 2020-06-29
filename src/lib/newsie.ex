defmodule Newsie do
  @moduledoc """
  Documentation for `Newsie`.
  """

  @version Mix.Project.config()[:version]

  @doc """
  HTTP User-Agent to send to remote APIs

  ### Example
      iex> Newsie.user_agent()
      "Newsie/#{@version}"
  """
  @spec user_agent() :: binary()
  def user_agent do
    "Newsie/#{version()}"
  end

  @doc "Get the current version of this library."
  @spec version() :: binary()
  def version, do: @version
end
