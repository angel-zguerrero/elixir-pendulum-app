defmodule SCExecutor.MixProject do
  use Mix.Project

  def project do
    [
      app: :scientific_calculator_executor,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :jason],
      mod: {SCExecutor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scientific_calculator_pubsub, in_umbrella: true},
      {:jason, "~> 1.4"}
    ]
  end
end
