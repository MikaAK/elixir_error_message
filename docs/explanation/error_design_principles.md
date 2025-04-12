# Error Design Principles

This document explains the design philosophy and principles behind the ErrorMessage library, helping you understand why it was created and how it can improve your application's error handling.

## Why Consistent Error Handling Matters

Error handling is a critical aspect of any robust application. Inconsistent error handling can lead to:

1. **Unpredictable behavior**: When errors are represented differently across your application, it becomes difficult to predict how errors will be structured.
2. **Fragile error handling**: String-based error matching is brittle and can break when error messages change.
3. **Poor user experience**: Inconsistent error reporting leads to confusing user interfaces and API responses.
4. **Difficult debugging**: Without structured errors, it's harder to track down the root cause of issues.

ErrorMessage addresses these problems by providing a consistent structure for all errors in your application.

## HTTP Status Codes as a Universal Language

ErrorMessage uses HTTP status codes as the foundation for error classification. This approach has several advantages:

1. **Universality**: HTTP status codes are widely understood across programming languages and platforms.
2. **Semantic meaning**: Each status code has a well-defined meaning (e.g., 404 for "not found", 403 for "forbidden").
3. **Standardization**: Using HTTP status codes means your error system aligns with web standards.
4. **API compatibility**: When building web APIs, your internal error representation maps directly to HTTP responses.

Even for non-web applications, HTTP status codes provide a comprehensive and well-understood taxonomy of error conditions that can be applied to many domains.

## The Three-Part Error Structure

ErrorMessage uses a three-part structure for errors:

1. **Code**: An atom representing the error type (e.g., `:not_found`, `:internal_server_error`)
2. **Message**: A human-readable description of what went wrong
3. **Details**: Additional context-specific information about the error

This structure provides a balance between:

- **Simplicity**: The core structure is easy to understand and use
- **Flexibility**: The details field can contain any data structure needed for your specific use case
- **Consistency**: All errors follow the same pattern, making them predictable

## Pattern Matching vs. String Matching

One of the key benefits of ErrorMessage is the ability to pattern match on error codes rather than error messages:

```elixir
# Fragile approach (depends on exact message text)
case result do
  {:error, "User not found: " <> _} -> handle_not_found()
  # ...
end

# Robust approach with ErrorMessage
case result do
  {:error, %ErrorMessage{code: :not_found}} -> handle_not_found()
  # ...
end
```

Pattern matching on error codes is:

1. **More robust**: Changing error messages doesn't break your error handling logic
2. **More explicit**: The intent of your code is clearer
3. **More maintainable**: Error handling code is less likely to break over time

## Serialization Considerations

ErrorMessage includes built-in support for converting errors to strings (for logging) and maps (for JSON serialization). This addresses common challenges with error serialization:

1. **Complex data structures**: The `ensure_json_serializable/1` function handles conversion of Elixir-specific data types (like PIDs, Date/Time structs, etc.) to JSON-compatible formats.
2. **Request context**: When available, the request ID is automatically included in serialized errors, making it easier to correlate errors with specific requests.
3. **Consistent output**: All errors are serialized in a consistent format, making it easier to process them in clients.

## Integration with Existing Systems

ErrorMessage is designed to integrate seamlessly with:

- **Phoenix**: For web API error responses
- **Logger**: For structured error logging
- **Plug**: For HTTP status code mapping

This integration-friendly design means you can adopt ErrorMessage incrementally in your application without having to rewrite existing code all at once.

## When to Use ErrorMessage

ErrorMessage is particularly valuable in:

1. **API-driven applications**: Where consistent error responses are crucial
2. **Microservice architectures**: Where errors might cross service boundaries
3. **Large codebases**: Where consistency across modules is important
4. **Long-lived applications**: Where maintainability over time is a priority

While ErrorMessage can be used in any Elixir application, these scenarios highlight where it provides the most value.
