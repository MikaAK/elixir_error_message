# ErrorMessage

ErrorMessage is a library designed to simplify error handling in Elixir applications by providing a consistent, HTTP-inspired error system. It creates a unified approach to error representation, making your code more predictable and maintainable.

## Key Features

- **Consistent Error Structure**: All errors follow the same format with code, message, and optional details
- **HTTP Status Code Integration**: Uses standard HTTP status codes as error codes
- **JSON Serialization**: Easy conversion to JSON for API responses
- **String Formatting**: Implementation of String.Chars protocol for easy logging
- **Type Specifications**: Comprehensive typespecs for better static analysis

## Documentation Structure

This documentation follows the [Diátaxis framework](https://diataxis.fr/), which organizes documentation into four distinct types:

1. **Tutorials**: Step-by-step lessons to help you get started with ErrorMessage
2. **How-To Guides**: Practical guides for solving specific problems
3. **Explanation**: Conceptual discussions about ErrorMessage's design and principles
4. **Reference**: Technical descriptions of ErrorMessage's modules, functions, and types

## Installation

Add `error_message` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:error_message, "~> 0.3.2"}
  ]
end
```

## Basic Usage

```elixir
# Create a not_found error with a message and details
error = ErrorMessage.not_found("User not found", %{user_id: 123})
# %ErrorMessage{code: :not_found, message: "User not found", details: %{user_id: 123}}

# Get the HTTP status code
ErrorMessage.http_code(error)  # Returns 404

# Convert to string for logging
to_string(error)  # Returns "not_found - User not found\nDetails: \n%{user_id: 123}"

# Convert to a map for JSON serialization
ErrorMessage.to_jsonable_map(error)
# %{code: :not_found, message: "User not found", details: %{user_id: 123}}
```

## Why Use ErrorMessage?

ErrorMessage helps you build more resilient applications by:

1. Providing a consistent error interface across your entire application
2. Making error handling more predictable and pattern-matchable
3. Simplifying API responses with proper HTTP status codes
4. Improving logging with meaningful error messages
5. Ensuring error details are properly serialized for various formats

Check out the rest of the documentation to learn more about how to use ErrorMessage effectively in your Elixir applications.
