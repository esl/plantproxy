defmodule Plantproxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :plantproxy,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Plantproxy.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:plug, "~> 1.6"},
      # {:cowboy, "~> 2.4"},
      {:httpoison, "~> 1.2"},
      {:plug, "~> 1.11"},
      {:cors_plug, "~> 2.0"},
      {:plug_cowboy, "~> 2.4"},
      {:nebulex, "~> 2.0"},
      # => When using :shards as backend
      {:shards, "~> 1.0"},
      {:decorator, "~> 1.3"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
