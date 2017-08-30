defmodule Authql.SessionResolver do
  require Logger

  def login(args, _info) do
    case Authql.create_session(args) do
      {:error, _reason} -> {:error, "Invalid email or password"}
      ok_session -> ok_session
    end
  end

  def logout(args, _info) do
    case Authql.delete_session(args) do
      {:error, _reason} -> {:error, "Unknown Token"}
      ok_session -> ok_session
    end
  end
end
