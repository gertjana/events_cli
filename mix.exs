defmodule Events.MixProject do
  use Mix.Project

  def project do
    [
      app: :events_cli,
      escript: [main_module: Events.CLI],
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Events, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_cli, "~> 0.1.0"},
      {:ex_prompt, "~> 0.1.5"},
      {:poison, "~> 3.1"},
      {:number, "~> 1.0.1"},
      {:scribe, "~> 0.10"}
    ]
  end
end
