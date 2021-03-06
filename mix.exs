defmodule Newsie.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :newsie,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Newsie",
      description: "Client library for accessing news APIs",
      source_url: "https://github.com/mroach/newsie",
      homepage_url: "https://github.com/mroach/newsie",
      docs: docs(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Michael Roach"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mroach/newsie"}
    ]
  end

  defp docs do
    [
      main: "About",
      logo: "priv/logo.png",
      nest_modules_by_prefix: [Newsie.Providers],
      extras: [
        "README.md": [filename: "About", title: "About Newsie"],
        "DEVELOPMENT.md": []
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Be explicit about environments for dependencies.
  # Using `:dev` would not only affect the development of this library itself,
  # but the dev mode of any apps that use this library.
  # We do not want to foist development dependencies upon users of the library.
  defp deps do
    [
      {:tesla, "~> 1.3.0"},
      {:jason, "~> 1.0"},

      # dev only
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},

      # test only
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false},
      {:credo, "~> 1.4", only: :test, runtime: false},
      {:dialyxir, "~> 1.0", only: :test, runtime: false}
    ]
  end
end
