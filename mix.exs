defmodule ErrorMessage.MixProject do
  use Mix.Project

  def project do
    [
      app: :error_message,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Error system to help make errors consistent across your system",
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [
      maintainers: ["Mika Kalathil"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MikaAK/error_message"},
      files: ~w(mix.exs README.md CHANGELOG.md lib)
    ]
  end

  defp docs do
    [
      main: "ErrorMessage",
      source_url: "https://github.com/MikaAK/error_message",
    ]
  end
end
