defmodule Authql do
  @moduledoc """
  Documentation for Authql.
  """
  import Ecto.Query, warn: false

  @repo Application.get_env(:authql, :repo)

  alias Authql.Session
  alias Authql.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    @repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: @repo.get!(User, id)

  @doc """
  Get a user by email and password

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("good@email.com", "good_password")
      {:ok, %User{}}

      iex> get_user!("bad_user", "bad_password")
      ** {:error, Ecto.NoResultsError}

      iex> get_user!("good_user", "bad_password")
      ** {:error, Ecto.NoResultsError}

  """
  def get_user(%{email: email, password: password}) do
    with %User{} = user <- @repo.get_by(User, email: email),
         {:ok, user} <- Comeonin.Bcrypt.check_pass(user, password)
    do {:ok, user}
    else _ -> {:error, Ecto.NoResultsError}
    end
  end


  @doc """
  Register a new user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> @repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> @repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    @repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    @repo.all(Session) |> @repo.preload(:user)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!("token")
      %Session{}

      iex> get_session!("bad_token")
      ** (Ecto.NoResultsError)

  """
  def get_session!(token) do
    Session
    |> @repo.get_by!(token: token)
    |> @repo.preload(:user)
  end

  @doc """
  Run this function if the given authentication info matches.
  Call from a GraphQL resolver function, with its args and info parameters.

  ## Examples

      iex> if_authenticated(good_args, good_info, fn user_id ->
        {:ok, "got user \#{user_id}"}
      end)
      {:ok, "got user 12"}

      iex> if_authenticated(bad_args, bad_info, fn user_id ->
        {:error, %{code: :unauthorized, error: "Unauthorized",
                   message: "Unauthorized"}}
      end)

  """
  def if_authenticated(%{viewer: user_id}, %{context: %{token: token}}, func) do
    if session_token_matches_user?(token, user_id) do
      func.(user_id)
    else
      unauthorized_error()
    end
  end
  def if_authenticated(_args, _info, _func), do: unauthorized_error()

  defp unauthorized_error do
    {:error, %{code: :unauthorized,
               error: "Unauthorized",
               message: "Unauthorized"}}
  end

  @doc """
  Verify that this session token matches this user.

  ## Examples

      iex> session_token_matches_user?(token_for_user_112, 112)
      true

      iex> session_token_matches_user?(token_for_user_112, 113)
      false

  """
  def session_token_matches_user?(token, user_id) do
    with %Session{} = session <- get_session!(token) do
      "#{session.user_id}" == "#{user_id}"
    else
      _ -> false
    end
  end

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{email: value, password: value})
      {:ok, %Session{}}

      iex> create_session(%{email: value, password: value, expires_at: value})
      {:ok, %Session{expires_at: value}}

      iex> create_session(%{field: bad_value})
      {:error, :invalid}

  """
  def create_session(attrs) do
    expires_at = attrs[:expires_at]
    with %{email: email, password: password} <- attrs,
         {:ok, user} <- get_user(%{email: email, password: password}),
         session_attrs = %{user: user, expires_at: expires_at},
         {:ok, session} <- Session.create_changeset(%Session{}, session_attrs)
                           |> @repo.insert()
      do
        {:ok, session}
      else
        _ -> {:error, :invalid}
    end
  end

  @doc """
  Deletes a Session.

  ## Examples

      iex> delete_session("token")
      {:ok, %Session{}}

      iex> delete_session("bad_token")
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%{token: token}) do
    with %Session{} = session <- get_session!(token) do
         @repo.delete(session)
    else
      error -> error
    end
  end
end
