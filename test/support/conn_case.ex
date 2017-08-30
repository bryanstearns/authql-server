defmodule Authql.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
    end
  end


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Authql.Repo)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
