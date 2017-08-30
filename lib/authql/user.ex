defmodule Authql.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Authql.User

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :admin, :boolean, default: false
    timestamps()
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 7)
    |> validate_format(:email, ~r/.@./)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> validate_length(:password, min: 7)
    |> validate_format(:email, ~r/.@./)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true,
                                         changes: %{password: password}
                                        } = changeset) do
    put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
    |> delete_change(:password)
  end
  defp put_password_hash(changeset), do: changeset
end
