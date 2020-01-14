defmodule SlowpokeArc.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :slowpoke_arc,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_path(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "SlowpokeArc",
      docs: docs(),

      # Hex
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      mod: {SlowpokeArc.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_path(:test), do: ["lib", "test/support"]
  defp elixirc_path(_), do: ["lib"]

  defp deps do
    [
      {:arc, ">= 0.8.0"},
      {:credo, "~> 1.0.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:ex_aws, "~> 2.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "SlowpokeArc",
      extras: ["README.md"],
      source_url: "https://github.com/Elonsoft/slowpoke_arc"
    ]
  end

  defp description do
    """
    Elixir lirary for image uploading
    """
  end

  defp package do
    [
      links: %{"GitHub" => "https://github.com/Elonsoft/slowpoke_arc"},
      licenses: ["MIT"],
      files: ~w(.formatter.exs mix.exs README.md LICENSE.md lib)
    ]
  end
end
