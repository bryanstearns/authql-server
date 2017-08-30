defmodule Authql.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Authql.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Authql.DataCase
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Authql.Repo)
  end
end
