defmodule Pear.Mixfile do
  use Mix.Project

  def project do
    [app: :pear,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: extra_applications(Mix.env),
     mod: {Pear, [start_bot: Mix.env != :test]}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Type "mix help deps" for more examples and options
  defp deps do
    [{:dotenv, "~> 2.0.0"},
     {:mix_docker, "~> 0.3.0"},
     {:slack, "~> 0.11.0"}]
  end

  defp extra_applications(:prod) do
    [:logger]
  end
  defp extra_applications(_) do
    [:dotenv, :logger]
  end
end
