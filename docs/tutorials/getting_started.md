# Getting Started with ErrorMessage

This tutorial will guide you through the basics of using ErrorMessage in your Elixir application. By the end, you'll understand how to create, handle, and serialize error messages.

## Prerequisites

- Basic knowledge of Elixir
- An Elixir project set up with Mix

## Step 1: Add ErrorMessage to Your Project

First, add ErrorMessage to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:error_message, "~> 0.3.2"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Step 2: Creating Your First Error Message

Let's start by creating a simple error message:

```elixir
# Create a basic not_found error
error = ErrorMessage.not_found("Resource not found")
```

This creates an `%ErrorMessage{}` struct with the code `:not_found` and the message "Resource not found".

## Step 3: Adding Details to Your Error

Error messages can include additional details to provide more context:

```elixir
# Create an error with details
error = ErrorMessage.not_found("User not found", %{user_id: 123})
```

The details can be any Elixir term, but keep in mind that if you plan to convert the error to JSON, you should use data structures that can be serialized.

## Step 4: Using Error Messages in Function Returns

A common pattern is to return `{:ok, result}` or `{:error, error_message}` from functions:

```elixir
defmodule UserRepository do
  def find_user(id) do
    case Database.get_user(id) do
      nil -> {:error, ErrorMessage.not_found("User not found", %{user_id: id})}
      user -> {:ok, user}
    end
  end
end
```

## Step 5: Pattern Matching on Error Codes

One of the benefits of ErrorMessage is the ability to pattern match on error codes:

```elixir
case UserRepository.find_user(123) do
  {:ok, user} -> 
    # Process the user
    IO.puts("Found user: #{user.name}")
    
  {:error, %ErrorMessage{code: :not_found}} ->
    # Handle not found specifically
    IO.puts("User not found, creating a new one")
    create_new_user(123)
    
  {:error, error} ->
    # Handle other errors
    IO.puts("Error: #{error.message}")
end
```

## Step 6: Converting Errors to Strings for Logging

ErrorMessage implements the `String.Chars` protocol, making it easy to convert errors to strings for logging:

```elixir
require Logger

def process_user(id) do
  case UserRepository.find_user(id) do
    {:ok, user} -> 
      {:ok, process(user)}
      
    {:error, error} = result ->
      Logger.error("Failed to find user: #{error}")
      result
  end
end
```

## Step 7: Converting Errors to JSON for API Responses

When building web APIs, you can easily convert error messages to JSON:

```elixir
defmodule MyAPI.ErrorView do
  def render("error.json", %{error: error}) do
    ErrorMessage.to_jsonable_map(error)
  end
end
```

## Next Steps

Now that you understand the basics of ErrorMessage, you can:

- Check out the [How-To Guides](https://hexdocs.pm/error_message/how-to-guides.html) for practical examples
- Explore the [Explanation](https://hexdocs.pm/error_message/explanation.html) section to understand the design principles
- Refer to the [API Reference](https://hexdocs.pm/error_message/api-reference.html) for detailed function documentation

Congratulations! You've completed the getting started tutorial for ErrorMessage.
