use Mix.Config

config :authql, Authql.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "authql_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :authql,
  repo: Authql.Repo,
  token_secret: "token_secret_token_secret"

# Speed up comeonin during tests
config :comeonin, :bcrypt_log_rounds, 4

config :logger, level: :warn
