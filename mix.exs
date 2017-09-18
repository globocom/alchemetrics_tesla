defmodule AlchemetricsTesla.Mixfile do
  use Mix.Project

  @description """
  AlchemetricsTesla is a Tesla middleware to report external call metrics.
  """

  @project_url "https://github.com/globocom/alchemetrics-tesla"

  def project do
    [
      app: :alchemetrics_tesla,
      version: "0.1.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: @description,
      source_url: @project_url,
      homepage_url: @project_url,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      name: "AlchemetricsTesla",
      docs: [
        main: "AlchemetricsTesla",
        source_url: @project_url,
      ],
     deps: deps()
   ]
  end

  def application, do: []

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:alchemetrics, "~> 0.3.0", only: :test},
      {:tesla, "~> 0.7.1", only: :test},
      {:mock, "~> 0.3.1", only: :test},
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [files: ["config", "lib", "mix.exs", "mix.lock", "README.md", "LICENSE"],
     maintainers: ["Globo.com"],
     licenses: ["MIT"],
     links: %{"GitHub" => @project_url},]
  end
end
