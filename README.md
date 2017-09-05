# authql-server - Authentication over GraphQL

This is the server side of a simple mechanism for doing email+password
authentication over [GraphQL](http://graphql.org/) in
[Elixir](https://elixir-lang.org/)/[Phoenix](http://phoenixframework.org/)
applications that use [Absinthe](http://absinthe-graphql.org/). The client side
is [authql-client](https://github.com/bryanstearns/authql-client),
and adds authentication support to
[React](https://facebook.github.io/react/) applications using
[React Apollo](http://dev.apollodata.com/react/).

I wrote it because I've created several applications that I want to deploy
publicly, but don't want to grant free-for-all access to my data, nor spend a
lot of time implementing authentication in each one :-)

[authql-example-server](https://github.com/bryanstearns/authql-example-server)
and [authql-example-client](https://github.com/bryanstearns/authql-example-client)
show how these libraries are used.

So far, I haven't published this on Hex, or written more documentation than
this README; if there's interest, I will. Certainly, if you see anything wrong
with what I've done here, please file an issue; pull requests gladly accepted,
too.
