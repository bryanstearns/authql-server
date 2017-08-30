defmodule Authql.SessionResolverTest do
  use Authql.DataCase
  alias Authql.Session
  alias Authql.SessionResolver

  test "creates a session when the email/password are good" do
    credentials = %{email: "x@y.com", password: "swordfish"}
    {:ok, _user} = Authql.register_user(credentials)
    assert {:ok, %Session{user: %{email: "x@y.com"}, token: _}} =
      SessionResolver.login(credentials, [])
  end

  test "returns an error when the email/password are bad" do
    assert {:error, _message} =
      SessionResolver.login(%{email: "user@example.com", password: "sekrit"}, [])
  end
end
