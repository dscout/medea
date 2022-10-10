defmodule Medea.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :medea,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        "test.ci": :test
      ],

      # Hex
      package: package(),
      description: "A fully structured JSON logger",

      # Dialyzer
      dialyzer: [
        plt_core_path: "_build/#{Mix.env()}",
        flags: [:error_handling, :underspecs]
      ],

      # Docs
      name: "Medea",
      docs: [
        main: "Medea",
        extras: ["CHANGELOG.md"],
        formatters: ["html"],
        source_ref: "v#{@version}",
        source_url: "https://github.com/dscout/medea"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def package do
    [
      maintainers: ["Parker Selbert"],
      licenses: ["Apache-2.0"],
      links: %{github: "https://github.com/dscout/medea"}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      "test.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "credo --strict",
        "test --raise",
        "dialyzer"
      ]
    ]
  end
end
