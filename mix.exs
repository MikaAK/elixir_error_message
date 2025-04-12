defmodule ErrorMessage.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_message,
      version: "0.3.3",
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

      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:ex_doc, ">= 0.0.0", optional: true, only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", optional: true, only: :test, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Mika Kalathil"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MikaAK/elixir_error_message"},
      files: ~w(mix.exs README.md CHANGELOG.md lib docs)
    ]
  end

  defp docs do
    [
      main: "overview",
      source_url: "https://github.com/MikaAK/elixir_error_message",
      extra_section: "DOCUMENTATION",
      extras: [
        "docs/overview.md",
        "docs/how-to-guides/error_handling_patterns.md",
        "docs/how-to-guides/phoenix_integration.md",
        "docs/explanation/error_design_principles.md",
        "docs/explanation/error_handling_in_elixir.md",
        "docs/reference/api_reference.md",
        "docs/reference/serialization.md",
        "docs/tutorials/error_handling_workflow.md",
        "docs/tutorials/getting_started.md",
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        Tutorials: ~r/docs\/tutorials\/.?/,
        "HowTo docs": ~r/docs\/how-to-guides\/.?/,
        Reference: ~r/docs\/reference\/.?/,
        Explanation: ~r/docs\/explanation\/.?/
      ],
      groups_for_modules: [
        "Core": [ErrorMessage]
      ]
    ]
  end
end
