defmodule ErrorMessage.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_message,
      version: "0.1.4",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Error system to help make errors consistent across your system",
      docs: docs(),
      package: package(),
      preferred_cli_env: [dialyzer: :test],
      dialyzer: [plt_add_apps: [:jason]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.13", optional: true, runtime: false, only: [:dev, :test]},
      {:jason, ">= 1.0.0", optional: true},

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
