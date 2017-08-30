defmodule Authql.UserTest do
  use Authql.DataCase
  alias Authql.User

  # Happy path is covered by AuthqlTest

  test "it requires the password on registration" do
    cs = User.registration_changeset(%User{}, %{email: "x@y.com"})
    refute cs.valid?
    assert %Ecto.Changeset{errors: [password: {"can't be blank",
                                               [validation: :required]}]} = cs
  end

  test "it doesn't require the password on update" do
    cs = User.changeset(%User{}, %{email: "x@y.com"})
    assert cs.valid?
  end

  test "it hashes the password on change" do
    cs = User.registration_changeset(%User{}, %{email: "x@y.com",
                                                password: "swordfish"})
    assert "$2b$" <> _ = Ecto.Changeset.get_change(cs, :password_hash)
    cs = User.changeset(%User{email: "x@y.com"}, %{password: "swordfish"})
    assert "$2b$" <> _ = Ecto.Changeset.get_change(cs, :password_hash)
  end

  test "it requires a properly-formatted email address" do
    cs = User.registration_changeset(%User{}, %{email: "bad",
                                                password: "swordfish"})
    refute cs.valid?
    assert %Ecto.Changeset{errors: [email: {"has invalid format",
                                            [validation: :format]}]} = cs
  end
end
