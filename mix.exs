defmodule Authql.Mixfile do
  use Mix.Project

  def project do
    [
      app: :authql,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Authql.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.3.0"},
      {:absinthe_ecto, "~> 0.1.0"},
      {:absinthe_plug, "~> 1.3.1"},
      {:bcrypt_elixir, "~> 0.12.1"},
      {:comeonin, "~> 4.0.0"},
      {:phoenix, "~> 1.3.0"},
      {:poison, ">= 3.1.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.1.24"}
    ]
  end
end
