defmodule Authql.WebContextTest do
  use Authql.ConnCase
  alias Authql.WebContext

  test "it records the token when it's present", %{conn: conn} do
    credentials = %{email: "a@b.com", password: "swordfish"}
    {:ok, _user} = Authql.register_user(credentials)
    {:ok, %{token: token}} =
      Authql.create_session(Map.put(credentials, :expires_at, nil))

    conn = %{conn | req_headers: [{"authorization", "Bearer #{token}"}]}
    |> WebContext.call()

    assert %{context: %{token: ^token}} = conn.private.absinthe
  end

  test "it doesn't note a token when not present", %{conn: conn} do
    conn = WebContext.call(conn)
    refute Map.has_key?(conn.private, :absinthe)
  end
end
