defmodule SlowpokeArc.MixProject do
  use Mix.Project

  def project do
    [
      app: :slowpoke_arc,
      version: "0.0.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_path(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_aws, "~> 2.0"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end
