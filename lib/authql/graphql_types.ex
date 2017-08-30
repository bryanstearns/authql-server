defmodule Authql.GraphQLTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :email, :string
    field :admin, :boolean
  end

  object :session do
    field :user, :user
    field :token, :string
  end

  object :authql_mutations do
    field :login, type: :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &Authql.SessionResolver.login/2
    end

    field :logout, type: :session do
      arg :token, non_null(:string)

      resolve &Authql.SessionResolver.logout/2
    end
  end
end
