# Error Handling in Elixir and ErrorMessage

This document explains how error handling typically works in Elixir and how ErrorMessage enhances the standard approach.

## Traditional Error Handling in Elixir

Elixir, like Erlang, follows the "Let it crash" philosophy, which encourages developers to focus on the happy path and let supervisors handle failures. However, this doesn't mean that we should ignore errors entirely. For expected errors that are part of normal program flow, Elixir provides several conventions:

### Return Values

The most common pattern in Elixir for handling errors is to return tagged tuples:

```elixir
# Success case
{:ok, result}

# Error case
{:error, reason}
```

This pattern allows for easy pattern matching:

```elixir
case MyModule.some_function() do
  {:ok, result} -> handle_success(result)
  {:error, reason} -> handle_error(reason)
end
```

### Exceptions

Elixir also supports exceptions for exceptional circumstances:

```elixir
try do
  some_function_that_might_raise()
rescue
  e in SomeError -> handle_error(e)
end
```

However, exceptions are generally used for unexpected errors rather than as a control flow mechanism.

## Limitations of Traditional Approaches

While these approaches work well for simple cases, they have limitations:

1. **Inconsistent Error Structure**: The `:error` tuple can contain any term as its reason, leading to inconsistent error handling across different parts of an application.

2. **String-Based Error Messages**: Many libraries use simple strings as error reasons, which makes pattern matching fragile.

3. **Limited Context**: Error reasons often lack detailed context about what went wrong.

4. **No Standard for HTTP Integration**: When building web applications, there's no standard way to map errors to HTTP status codes.

## How ErrorMessage Improves Error Handling

ErrorMessage addresses these limitations by providing:

### 1. Consistent Structure

All errors follow the same structure:

```elixir
%ErrorMessage{
  code: :error_code,
  message: "Human-readable message",
  details: additional_context
}
```

This consistency makes error handling more predictable across your application.

### 2. Code-Based Pattern Matching

Instead of matching on error messages (which might change), you can match on error codes:

```elixir
case result do
  {:ok, value} -> handle_success(value)
  {:error, %ErrorMessage{code: :not_found}} -> handle_not_found()
  {:error, %ErrorMessage{code: :unauthorized}} -> handle_unauthorized()
  {:error, _} -> handle_other_errors()
end
```

### 3. Rich Context

The `details` field can contain any data structure, allowing you to provide rich context about what went wrong:

```elixir
ErrorMessage.not_found("User not found", %{
  user_id: id,
  search_params: params,
  timestamp: DateTime.utc_now()
})
```

### 4. HTTP Integration

ErrorMessage is built around HTTP status codes, making it easy to integrate with web applications:

```elixir
def render_error(conn, %ErrorMessage{} = error) do
  conn
  |> put_status(ErrorMessage.http_code(error))
  |> json(ErrorMessage.to_jsonable_map(error))
end
```

## ErrorMessage in the Elixir Ecosystem

ErrorMessage complements other Elixir error handling approaches:

### With Standard Libraries

ErrorMessage works alongside standard Elixir patterns:

```elixir
def find_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, ErrorMessage.not_found("User not found", %{user_id: id})}
    user -> {:ok, user}
  end
end
```

### With Ecto

You can convert Ecto changeset errors to ErrorMessage:

```elixir
def create_user(params) do
  %User{}
  |> User.changeset(params)
  |> Repo.insert()
  |> case do
    {:ok, user} -> 
      {:ok, user}
    {:error, changeset} ->
      errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
      {:error, ErrorMessage.unprocessable_entity("Invalid user data", errors)}
  end
end
```

### With Phoenix

ErrorMessage integrates well with Phoenix for API error handling:

```elixir
defmodule MyApp.FallbackController do
  use Phoenix.Controller
  
  def call(conn, {:error, %ErrorMessage{} = error}) do
    conn
    |> put_status(ErrorMessage.http_code(error))
    |> put_view(MyApp.ErrorView)
    |> render("error.json", error: error)
  end
end
```

## When to Use ErrorMessage

ErrorMessage is particularly valuable in:

1. **API-driven applications**: Where consistent error responses are crucial
2. **Complex business logic**: Where detailed error context helps with debugging
3. **Cross-module boundaries**: Where consistent error handling improves maintainability
4. **Web applications**: Where mapping errors to HTTP status codes is important

Most systems will benefit from ErrorMessage providing significant benefits for applications that need structured, consistent error handling, as well as benefitting pattern matching on error codes.

For further reading checkout this [blog post](https://learn-elixir.dev/blogs/safer-error-systems-in-elixir)
