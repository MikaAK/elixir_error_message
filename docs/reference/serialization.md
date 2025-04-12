# Error Serialization Reference

This document provides detailed information about how ErrorMessage handles serialization of error messages to different formats.

## String Serialization

ErrorMessage implements the `String.Chars` protocol, which allows error messages to be converted to strings using `to_string/1` or string interpolation.

### Basic Format

The string representation of an error message follows this format:

- For errors without details: `"#{code} - #{message}"`
- For errors with details: `"#{code} - #{message}\nDetails: \n#{inspect(details, pretty: true)}"`

### Examples

```elixir
# Error without details
error = ErrorMessage.not_found("User not found")
to_string(error)  # "not_found - User not found"

# Error with details
error = ErrorMessage.internal_server_error("Database error", %{table: "users", reason: :connection_lost})
to_string(error)
# "internal_server_error - Database error
# Details: 
# %{reason: :connection_lost, table: "users"}"

# String interpolation
"Error occurred: #{error}"
# "Error occurred: internal_server_error - Database error
# Details: 
# %{reason: :connection_lost, table: "users"}"
```

## JSON Serialization

ErrorMessage provides the `to_jsonable_map/1` function to convert error messages to maps suitable for JSON serialization.

### Basic Format

The JSON representation of an error message follows this format:

```json
{
  "code": "error_code",
  "message": "Error message",
  "details": { ... }
}
```

If a request ID is available in the Logger metadata, it will be included:

```json
{
  "code": "error_code",
  "message": "Error message",
  "details": { ... },
  "request_id": "FzMx0iBDvDDJ-GkAAAfh"
}
```

### Data Type Handling

The `ErrorMessage.Serializer` module includes the `ensure_json_serializable/1` function, which handles conversion of Elixir-specific data types to JSON-compatible formats:

| Elixir Type | JSON Representation |
|-------------|---------------------|
| `Date` | ISO 8601 date string |
| `Time` | ISO 8601 time string |
| `DateTime` | ISO 8601 datetime string |
| `NaiveDateTime` | ISO 8601 datetime string |
| `Struct` | `{"struct": "StructName", "data": {...}}` |
| `Tuple` | Array |
| `PID` | String representation (with registered name if available) |
| `Function` | `{"module": "Module", "function": "function_name", "arity": n}` |
| `List` | Array with each element converted recursively |
| `Map` | Object with each value converted recursively |
| Other types | Passed through as-is |

### Examples

```elixir
# Basic error
error = ErrorMessage.not_found("User not found", %{user_id: 123})
ErrorMessage.to_jsonable_map(error)
# %{code: :not_found, message: "User not found", details: %{user_id: 123}}

# Error with complex details
error = ErrorMessage.bad_request("Invalid data", %{
  date: ~D[2023-01-15],
  time: ~T[14:30:00],
  callback: &String.length/1,
  user: %UserStruct{name: "John", created_at: ~N[2023-01-01 00:00:00]}
})

ErrorMessage.to_jsonable_map(error)
# %{
#   code: :bad_request,
#   message: "Invalid data",
#   details: %{
#     date: "2023-01-15",
#     time: "14:30:00",
#     callback: %{module: "Elixir.String", function: "length", arity: 1},
#     user: %{
#       struct: "UserStruct",
#       data: %{
#         name: "John",
#         created_at: "2023-01-01T00:00:00"
#       }
#     }
#   }
# }
```

### Direct JSON Encoding

If the Jason library is available, ErrorMessage automatically implements the `Jason.Encoder` protocol, allowing error messages to be directly encoded to JSON:

```elixir
# With Jason available
Jason.encode!(ErrorMessage.not_found("User not found"))
# "{\"code\":\"not_found\",\"message\":\"User not found\"}"

# With details
Jason.encode!(ErrorMessage.not_found("User not found", %{user_id: 123}))
# "{\"code\":\"not_found\",\"message\":\"User not found\",\"details\":{\"user_id\":123}}"
```

Note that when using `Jason.encode!/1` directly on an `%ErrorMessage{}` struct, the serialization of complex data types in the details field may not be handled as thoroughly as when using `ErrorMessage.to_jsonable_map/1` first. For the most reliable JSON serialization, especially with complex data structures, use:

```elixir
error
|> ErrorMessage.to_jsonable_map()
|> Jason.encode!()
```

## Integration with Phoenix

When using ErrorMessage with Phoenix, you can easily render error messages as JSON responses:

```elixir
defmodule MyApp.ErrorView do
  use MyApp, :view
  
  def render("error.json", %{error: error}) do
    ErrorMessage.to_jsonable_map(error)
  end
end
```

This will produce JSON responses with the appropriate structure and data type handling.
