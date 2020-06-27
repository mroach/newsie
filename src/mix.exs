defmodule Newsie.MixProject do
  use Mix.Project

  def project do
    [
      app: :newsie,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.3.0"},
      {:jason, "~> 1.0"},

      # env-restricted deps
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
