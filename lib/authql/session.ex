defmodule Authql.Session do
  use Ecto.Schema
  import Ecto.Changeset
  alias Authql.Session
  alias Authql.User

  @token_secret Application.get_env(:authql, :token_secret)
  @token_valid_duration (:timer.hours(24) * 14)

  schema "sessions" do
    field :expires_at, :utc_datetime
    field :token, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def create_changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:expires_at])
    |> put_assoc(:user, attrs.user)
    |> add_default_expires_at()
    |> add_token()
  end

  defp add_default_expires_at(changeset) do
    case get_change(changeset, :expires_at) do
      nil ->
        put_change(changeset, :expires_at, default_expires_at())
      _ ->
        changeset
    end
  end

  defp default_expires_at do
    DateTime.utc_now
    |> DateTime.to_unix(:millisecond)
    |> Kernel.+(@token_valid_duration)
    |> DateTime.from_unix!(:millisecond)
    |> Map.put(:microsecond, {0, 6})
  end

  defp add_token(changeset) do
    user = get_field(changeset, :user)
    put_change(changeset, :token, make_token(user.id))
  end

  defp make_token(user_id) do
    Phoenix.Token.sign(@token_secret, Integer.to_string(user_id),
                       :crypto.strong_rand_bytes(32))
  end
end
