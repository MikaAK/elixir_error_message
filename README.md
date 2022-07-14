ErrorMessage
===
[![Coverage](https://github.com/MikaAK/elixir_error_message/actions/workflows/coverage.yml/badge.svg)](https://github.com/MikaAK/elixir_error_message/actions/workflows/coverage.yml)
[![Test](https://github.com/MikaAK/elixir_error_message/actions/workflows/test.yml/badge.svg)](https://github.com/MikaAK/elixir_error_message/actions/workflows/test.yml)
[![Dialyzer](https://github.com/MikaAK/elixir_error_message/actions/workflows/dialyzer.yml/badge.svg)](https://github.com/MikaAK/elixir_error_message/actions/workflows/dialyzer.yml)
[![Credo](https://github.com/MikaAK/elixir_error_message/actions/workflows/credo.yml/badge.svg)](https://github.com/MikaAK/elixir_error_message/actions/workflows/credo.yml)
[![codecov](https://codecov.io/gh/MikaAK/elixir_error_message/branch/master/graph/badge.svg?token=V0JJA5AZ1H)](https://codecov.io/gh/MikaAK/elixir_error_message)
[![Hex pm](http://img.shields.io/hexpm/v/error_message.svg?style=flat)](https://hex.pm/packages/error_message)

This library exists to simplify error systems in a code base
and allow for a simple unified experience when using and reading
error messages around the code base

This creates one standard, that all errors should fit into the context
of HTTP error codes, if they don't `:internal_server_error` should
be used and you can use the message and details to provide a further
level of depth

### Installation

The package can be installed by adding `error_message` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:error_message, "~> 0.2.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/error_message](https://hexdocs.pm/error_message).


### Usage Example

```elixir
iex> id = 1
iex> ErrorMessage.not_found("no user with id #{id}", %{user_id: id})
%ErrorMessage{
  code: :not_found,
  message: "no user with id 1",
  details: %{user_id: 1}
}

iex> ErrorMessage.internal_server_error("critical internal error", %{
...>   reason: :massive_issue_with_x
...> })
%ErrorMessage{
  code: :internal_server_error,
  message: "critical internal error",
  details: %{reason: :massive_issue_with_x}
}
```

### Why is this important
If we want to have a good way to catch errors around our system as well as be able to
display errors that happen throughout our system, it's useful to have a common error
api so we can predict what will come out of a system

For example if we used elixir through our server, we would be able to catch a not found
pretty easily since we can predict the error code coming in without needing to
know the message. This leads to more resilliant code since message changes won't break
the functionality of your application

```elixir
# Because our error system is setup with `find_user` we can easily
# catch no users and have a solid backup plan
with {:error, %ErrorMessage{code: :not_found}} <- find_user(%{name: "bill"}) do
  create_user(%{name: "bill"})
end
```

### Usage with Phoenix
Another benefit is error rendering to the frontend, because all our errors are part of
the HTTP error system, it's quite easy to now return the proper status codes and messages
to our frontend clients. For example:

```elixir
defmodule MyController do
  def index(conn, param) do
    case find_thing(params) do
      {:ok, res} -> json(conn, res)
      {:error, e} -> json_error(conn, e)
    end
  end

  defp json_error(conn, %ErrorMessage{code: code} = e) do
    conn
      |> put_status(code) # Plug.Conn
      |> json(ErrorMessage.to_jsonable_map(e))
  end
end
```

*This will also add a request_id from `Logger.metadata[:request_id]` when found*


### Usage with Logger
Ontop of being useful for Phoenix we can also find some good use from this
system and Logger, since `ErrorMessage` implements `String.Chars` protocol

```elixir
case do_thing() do
  {:ok, value} -> {:ok, do_other_thing(value)}
  {:error, e} = res ->
    Logger.error("[MyModule] \#{e}")
    Logger.warn(to_string(e))

    res
end

```
