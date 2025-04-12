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
      main: "overview",
      source_url: "https://github.com/MikaAK/elixir_error_message",
      extra_section: "DOCUMENTATION",
      extras: [
        "docs/overview.md",
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        "Guides": [
          "docs/overview.md",
        ],
        "Tutorials": Path.wildcard("docs/tutorials/*.md"),
        "How-To Guides": Path.wildcard("docs/how-to-guides/*.md"),
        "Explanation": Path.wildcard("docs/explanation/*.md"),
        "Reference": Path.wildcard("docs/reference/*.md")
      ],
      groups_for_modules: [
        "Core": [ErrorMessage],
        "Serialization": [ErrorMessage.Serializer]
      ]
    ]
  end
end
