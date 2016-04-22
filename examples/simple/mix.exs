defmodule Simple.Mixfile do
  use Mix.Project

  def project do
    [app: :simple,
     version: "0.0.1",
     deps: deps]
  end

  def application do
    [mod: {Simple.App, []},
     applications: [:dynamodb_ecto, :ecto]]
  end

  defp deps do
    [{:dynamodb_ecto, path: "../.."},
     {:ecto, path: "../../deps/ecto", override: true},
     {:dynamodb, path: "../../deps/dynamodb", override: true}]
  end
end
