defmodule Authql.WebContext do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _ \\ nil) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      put_private(conn, :absinthe, %{context: %{token: token}})
    else
      _ -> conn
    end
  end
end
