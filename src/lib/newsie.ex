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
  @spec user_agent() :: String.t()
  def user_agent do
    "Newsie/#{@version}"
  end
end
