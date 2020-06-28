defmodule Newsie.MixProject do
  use Mix.Project

  def project do
    [
      app: :newsie,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Newsie",
      homepage_url: "https://github.com/mroach/newsie",
      docs: [
        main: "Newsie"
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
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

      # linter-only
      {:credo, "~> 1.4", only: :lint, runtime: false},
      {:dialyxir, "~> 1.0", only: :lint, runtime: false},

      # docs-only
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},

      # test-only
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false}
    ]
  end
end
