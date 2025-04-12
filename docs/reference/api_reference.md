# API Reference

This reference document provides detailed information about the ErrorMessage API, including all available functions, their parameters, and return types.

## Core Module: `ErrorMessage`

The main module that provides functions for creating and manipulating error messages.

### Error Creation Functions

ErrorMessage provides a function for each HTTP status code. Here are some of the most commonly used ones:

#### Client Error Functions

```elixir
ErrorMessage.bad_request(message, details \\ nil)
ErrorMessage.unauthorized(message, details \\ nil)
ErrorMessage.forbidden(message, details \\ nil)
ErrorMessage.not_found(message, details \\ nil)
ErrorMessage.method_not_allowed(message, details \\ nil)
ErrorMessage.not_acceptable(message, details \\ nil)
ErrorMessage.request_timeout(message, details \\ nil)
ErrorMessage.conflict(message, details \\ nil)
ErrorMessage.gone(message, details \\ nil)
ErrorMessage.unprocessable_entity(message, details \\ nil)
ErrorMessage.too_many_requests(message, details \\ nil)
```

#### Server Error Functions

```elixir
ErrorMessage.internal_server_error(message, details \\ nil)
ErrorMessage.not_implemented(message, details \\ nil)
ErrorMessage.bad_gateway(message, details \\ nil)
ErrorMessage.service_unavailable(message, details \\ nil)
ErrorMessage.gateway_timeout(message, details \\ nil)
```

Each function creates an `%ErrorMessage{}` struct with the appropriate error code, message, and optional details.

### Utility Functions

#### `to_string/1`

Converts an error message to a string representation.

```elixir
@spec to_string(error_message :: t) :: String.t()
```

Example:
```elixir
iex> ErrorMessage.to_string(ErrorMessage.not_found("User not found"))
"not_found - User not found"

iex> ErrorMessage.to_string(ErrorMessage.internal_server_error("Error", %{reason: :timeout}))
"internal_server_error - Error\nDetails: \n%{reason: :timeout}"
```

#### `to_jsonable_map/1`

Converts an error message to a map suitable for JSON serialization.

```elixir
@spec to_jsonable_map(error_message :: t) :: t_map
```

Example:
```elixir
iex> ErrorMessage.to_jsonable_map(ErrorMessage.not_found("User not found", %{id: 123}))
%{code: :not_found, message: "User not found", details: %{id: 123}}
```

If a request ID is available in the Logger metadata, it will be included in the map:

```elixir
%{
  code: :not_found,
  message: "User not found",
  details: %{id: 123},
  request_id: "FzMx0iBDvDDJ-GkAAAfh"
}
```

#### `http_code/1`

Returns the HTTP status code for an error message or error code atom.

```elixir
@spec http_code(error_code :: code) :: non_neg_integer()
@spec http_code(error_message :: t) :: non_neg_integer()
```

Example:
```elixir
iex> ErrorMessage.http_code(:not_found)
404

iex> ErrorMessage.http_code(ErrorMessage.internal_server_error("Error"))
500
```

#### `http_code_reason_atom/1`

Returns the HTTP reason as an atom for the HTTP error code.

```elixir
@spec http_code_reason_atom(error_code :: non_neg_integer()) :: code
```

Example:
```elixir
iex> ErrorMessage.http_code_reason_atom(404)
:not_found

iex> ErrorMessage.http_code_reason_atom(500)
:internal_server_error
```

## Types

### `ErrorMessage.t`

The main error message struct type.

```elixir
@type t :: %ErrorMessage{code: code, message: String.t(), details: any()}
@type t(details) :: %ErrorMessage{code: code, message: String.t(), details: details}
```

### `ErrorMessage.code`

The error code type, which is an atom representing an HTTP status code.

```elixir
@type code :: :multiple_choices
            | :moved_permanently
            | :found
            | :see_other
            | :not_modified
            | :use_proxy
            | :switch_proxy
            | :temporary_redirect
            | :permanent_redirect
            | :bad_request
            | :unauthorized
            | :payment_required
            | :forbidden
            | :not_found
            | :method_not_allowed
            | :not_acceptable
            | :proxy_authentication_required
            | :request_timeout
            | :conflict
            | :gone
            | :length_required
            | :precondition_failed
            | :request_entity_too_large
            | :request_uri_too_long
            | :unsupported_media_type
            | :requested_range_not_satisfiable
            | :expectation_failed
            | :im_a_teapot
            | :misdirected_request
            | :unprocessable_entity
            | :locked
            | :failed_dependency
            | :too_early
            | :upgrade_required
            | :precondition_required
            | :too_many_requests
            | :request_header_fields_too_large
            | :unavailable_for_legal_reasons
            | :internal_server_error
            | :not_implemented
            | :bad_gateway
            | :service_unavailable
            | :gateway_timeout
            | :http_version_not_supported
            | :variant_also_negotiates
            | :insufficient_storage
            | :loop_detected
            | :not_extended
            | :network_authentication_required
```

### Result Types

ErrorMessage provides several type specifications for common result patterns:

```elixir
@type t_res :: {:ok, term} | {:error, t}
@type t_res(result_type) :: {:ok, result_type} | {:error, t}
@type t_res(result_type, details_type) :: {:ok, result_type} | {:error, t(details_type)}

@type t_ok_res :: :ok | {:error, t}
@type t_ok_res(details_type) :: :ok | {:error, t(details_type)}
```

### Map Types

Types for the map representation of error messages:

```elixir
@type t_map :: %{code: code, message: String.t(), details: any(), request_id: String.t()} |
               %{code: code, message: String.t(), details: any()}

@type t_map(details) :: %{code: code, message: String.t(), details: details, request_id: String.t()} |
                        %{code: code, message: String.t(), details: details}
```

## Protocols

### `String.Chars`

ErrorMessage implements the `String.Chars` protocol, allowing error messages to be converted to strings using `to_string/1` or string interpolation:

```elixir
defimpl String.Chars do
  def to_string(%ErrorMessage{} = e) do
    ErrorMessage.to_string(e)
  end
end
```

Example:
```elixir
iex> "Error: #{ErrorMessage.not_found("User not found")}"
"Error: not_found - User not found"
```

### `Jason.Encoder` (Optional)

If the Jason library is available, ErrorMessage automatically implements the `Jason.Encoder` protocol, allowing error messages to be directly encoded to JSON:

```elixir
if Enum.any?(Application.loaded_applications(), fn {dep_name, _, _} -> dep_name === :jason end) do
  @derive Jason.Encoder
end
```

Example:
```elixir
iex> Jason.encode!(ErrorMessage.not_found("User not found"))
"{\"code\":\"not_found\",\"message\":\"User not found\"}"
```
