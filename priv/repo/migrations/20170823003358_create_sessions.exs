defmodule Authql.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string
      add :expires_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:sessions, [:token])
    create index(:sessions, [:user_id])
  end
end
