defmodule ErrorMessage.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_message,
      version: "0.3.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Error system to help make errors consistent across your system",
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix, :credo, :jason],
        list_unused_filters: true,
        plt_local_path: "dialyzer",
        plt_core_path: "dialyzer",
        flags: [:unmatched_returns]
      ],
      preferred_cli_env: [
        dialyzer: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.13"},
      {:jason, ">= 1.0.0", optional: true},

      {:credo, "~> 1.6", only: [:test, :dev], runtime: false},
      {:blitz_credo_checks, "~> 0.1", only: [:test, :dev], runtime: false},

      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.0.0", optional: true, only: :dev},
      {:dialyxir, "~> 1.0", optional: true, only: :test, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Mika Kalathil"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MikaAK/elixir_error_message"},
      files: ~w(mix.exs README.md CHANGELOG.md lib)
    ]
  end

  defp docs do
    [
      main: "ErrorMessage",
      source_url: "https://github.com/MikaAK/elixir_error_message"
    ]
  end
end
