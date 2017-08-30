defmodule AuthqlTest do
  use Authql.DataCase

  alias Authql.Session
  alias Authql.User

  @valid_user_attrs %{email: "bob@example.com", password: "some password"}
  @update_user_attrs %{email: "ann@example.com", password: "updated password"}
  @invalid_user_attrs %{email: "bad", password: ""}

  @valid_session_attrs @valid_user_attrs
  @invalid_session_attrs @invalid_user_attrs

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Authql.register_user()

    user
  end

  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(@valid_session_attrs)
      |> Authql.create_session()

    session
  end

  setup_all do
    user = user_fixture()
    session = session_fixture()

    %{user: user, session: session}
  end

  describe "users" do
    test "list_users/0 returns all users", %{user: user} do
      assert Authql.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Authql.get_user!(user.id) == user
    end

    test "register_user/1 with valid data creates a user", %{user: user} do
      assert user.email == "bob@example.com"
      assert "$2b$" <> _ = user.password_hash
      refute user.admin
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authql.register_user(@invalid_user_attrs)
    end

    test "update_user/2 with valid data updates the user", %{user: user} do
      old_password_hash = user.password_hash
      assert {:ok, user} = Authql.update_user(user, @update_user_attrs)
      assert %User{} = user
      assert user.email == "ann@example.com"
      assert old_password_hash != user.password_hash
    end

    test "update_user/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Authql.update_user(user, @invalid_user_attrs)
      assert user == Authql.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture(%{email: "fred@example.com", password: "some password"})
      assert {:ok, %User{}} = Authql.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Authql.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Authql.change_user(user)
    end
  end

  describe "sessions" do
    test "list_sessions/0 returns all sessions", %{session: session} do
      assert Authql.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given token", %{session: session} do
      assert Authql.get_session!(session.token) == session
    end

    test "if_authenticated?/2 with good args/info calls function", %{session: session} do
      user_id = session.user_id
      assert {:ok, ^user_id} =
        Authql.if_authenticated(%{viewer: session.user_id},
                                %{context: %{token: session.token}}, fn uid ->
          {:ok, uid}
        end)
    end

    test "if_authenticated?/2 with bad args/info returns error", %{session: session} do
      assert {:error, %{code: :unauthorized, error: "Unauthorized",
                        message: "Unauthorized"}} =
        Authql.if_authenticated(%{viewer: session.user_id + 1},
                                %{context: %{token: session.token}}, fn uid ->
          {:ok, uid}
        end)
    end

    test "session_token_matches_user?/2 verifies that they match", %{session: session} do
      assert Authql.session_token_matches_user?(session.token, session.user_id)
      refute Authql.session_token_matches_user?(session.token, session.user_id + 1)
    end

    test "create_session/1 with valid data creates a session", %{user: user} do
      expected_expires = DateTime.utc_now
      |> DateTime.to_unix(:millisecond)
      |> Kernel.+(14 * :timer.hours(24))
      |> Kernel./(1000)

      assert {:ok, %Session{} = session} = Authql.create_session(@valid_session_attrs)
      assert String.length(session.token) > 100
      assert session.user_id == user.id
      assert_in_delta DateTime.to_unix(session.expires_at, :second),
                      expected_expires, 3

      overridden_expires_at = Timex.now
      creds_with_expiration = Map.put(@valid_session_attrs, :expires_at,
                                      overridden_expires_at)
      assert {:ok, %Session{expires_at: ^overridden_expires_at}} =
        Authql.create_session(creds_with_expiration)
    end

    test "create_session/1 with invalid data returns error" do
      assert {:error, :invalid} = Authql.create_session(@invalid_session_attrs)
    end

    test "delete_session/1 deletes the session", %{session: session} do
      assert {:ok, %Session{}} = Authql.delete_session(%{token: session.token})
      assert_raise Ecto.NoResultsError, fn -> Authql.get_session!(session.token) end
    end
  end
end
