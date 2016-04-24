defmodule Dynamo.Ecto.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :dynamodb_ecto,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     description: description,
     package: package,
     docs: docs]
  end

  def application do
    [applications: [:ecto, :dynamodb, :ex_aws, :httpoison]]
  end

  defp deps do
    [
      {:ex_aws,    ">= 0.0.0"},
      {:poison, "~> 1.2"}, # unsure why/if needed to specify here, `iex -S mix` errored without this
      {:httpoison, ">= 0.0.0"},
      {:uuid, "~> 1.1" },
      {:ecto, "~> 1.0.0"},
      {:dialyze, "~> 0.2.0", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
      {:inch_ex, "~> 0.5", only: :docs},
      {:earmark, "~> 0.2", only: :docs},
      {:ex_doc, "~> 0.11", only: :docs}
    ]
  end

  defp description do
    """
    DynamoDB adapter for Ecto
    """
  end

  defp package do
    [maintainers: ["Brian Glusman"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/bglusman/dynamodb_ecto"},
     files: ~w(mix.exs README.md CHANGELOG.md lib)]
  end

  defp docs do
    [source_url: "https://github.com/bglusman/dynamodb_ecto",
     source_ref: "v#{@version}",
     main: "readme",
     extras: ["README.md"]]
  end
end
