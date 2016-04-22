use Mix.Config

config :simple, Simple.Repo,
  adapter: Dynamo.Ecto,
  database: "ecto_simple",
  hostname: "localhost"
