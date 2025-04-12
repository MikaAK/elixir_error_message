# Building an Error Handling Workflow

This tutorial will guide you through creating a complete error handling workflow using ErrorMessage in an Elixir application. We'll build a simple user management system that demonstrates how to use ErrorMessage throughout different layers of your application.

## Prerequisites

- Basic knowledge of Elixir
- ErrorMessage library installed
- Basic understanding of Ecto (optional, for the database example)

## Step 1: Define Your Domain Logic

Let's start by defining a simple user management module:

```elixir
defmodule MyApp.Users do
  @moduledoc """
  User management functionality
  """
  
  # In-memory user database for this example
  @users %{
    1 => %{id: 1, name: "Alice", email: "alice@example.com", role: :admin},
    2 => %{id: 2, name: "Bob", email: "bob@example.com", role: :user}
  }
  
  @doc """
  Get a user by ID
  """
  @spec get_user(integer()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def get_user(id) when is_integer(id) do
    case Map.get(@users, id) do
      nil -> 
        {:error, ErrorMessage.not_found("User not found", %{user_id: id})}
      user -> 
        {:ok, user}
    end
  end
  
  @doc """
  Get a user by email
  """
  @spec get_user_by_email(String.t()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def get_user_by_email(email) when is_binary(email) do
    user = Enum.find_value(@users, fn {_id, user} -> 
      if user.email == email, do: user
    end)
    
    case user do
      nil -> 
        {:error, ErrorMessage.not_found("User not found", %{email: email})}
      user -> 
        {:ok, user}
    end
  end
  
  @doc """
  Update a user
  """
  @spec update_user(integer(), map()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def update_user(id, params) when is_integer(id) and is_map(params) do
    with {:ok, user} <- get_user(id),
         {:ok, updated_user} <- validate_update(user, params) do
      # In a real app, we would persist the changes
      {:ok, updated_user}
    end
  end
  
  defp validate_update(user, %{role: role} = params) do
    case role do
      role when role in [:admin, :user] ->
        {:ok, Map.merge(user, Map.take(params, [:name, :email, :role]))}
      _ ->
        {:error, ErrorMessage.unprocessable_entity("Invalid role", %{
          allowed_roles: [:admin, :user],
          provided_role: role
        })}
    end
  end
  
  defp validate_update(user, params) do
    {:ok, Map.merge(user, Map.take(params, [:name, :email]))}
  end
end
```

## Step 2: Create a Service Layer

Now, let's create a service layer that uses our domain logic and adds additional business rules:

```elixir
defmodule MyApp.UserService do
  @moduledoc """
  User service with business logic
  """
  
  alias MyApp.Users
  
  @doc """
  Get user profile with authorization check
  """
  @spec get_profile(integer(), map()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def get_profile(user_id, current_user) do
    with {:ok, user} <- Users.get_user(user_id),
         :ok <- authorize_profile_access(user, current_user) do
      {:ok, format_profile(user)}
    end
  end
  
  @doc """
  Update user with authorization check
  """
  @spec update_profile(integer(), map(), map()) :: {:ok, map()} | {:error, ErrorMessage.t()}
  def update_profile(user_id, params, current_user) do
    with {:ok, user} <- Users.get_user(user_id),
         :ok <- authorize_profile_update(user, current_user),
         {:ok, updated_user} <- Users.update_user(user_id, params) do
      {:ok, format_profile(updated_user)}
    end
  end
  
  # Authorization helpers
  
  defp authorize_profile_access(user, current_user) do
    cond do
      current_user.id == user.id -> :ok
      current_user.role == :admin -> :ok
      true -> {:error, ErrorMessage.forbidden("Not authorized to view this profile")}
    end
  end
  
  defp authorize_profile_update(user, current_user) do
    cond do
      current_user.id == user.id -> :ok
      current_user.role == :admin -> :ok
      true -> {:error, ErrorMessage.forbidden("Not authorized to update this profile")}
    end
  end
  
  # Format user for API response
  
  defp format_profile(user) do
    Map.take(user, [:id, :name, :email, :role])
  end
end
```

## Step 3: Create a Controller Layer

Now, let's create a controller that would handle HTTP requests in a Phoenix application:

```elixir
defmodule MyApp.UserController do
  @moduledoc """
  Controller for user endpoints
  """
  
  # In a real Phoenix app, you would use: use MyApp.Web, :controller
  
  alias MyApp.UserService
  
  @doc """
  Get user profile
  """
  def show(conn, %{"id" => id_string}) do
    # Get the current user from the session/token (simplified for this example)
    current_user = conn.assigns.current_user
    
    with {:ok, id} <- parse_id(id_string),
         {:ok, profile} <- UserService.get_profile(id, current_user) do
      # In a real Phoenix app: render(conn, "show.json", user: profile)
      {:ok, profile}
    else
      {:error, error} -> render_error(conn, error)
    end
  end
  
  @doc """
  Update user profile
  """
  def update(conn, %{"id" => id_string, "user" => user_params}) do
    current_user = conn.assigns.current_user
    
    with {:ok, id} <- parse_id(id_string),
         {:ok, profile} <- UserService.update_profile(id, user_params, current_user) do
      # In a real Phoenix app: render(conn, "show.json", user: profile)
      {:ok, profile}
    else
      {:error, error} -> render_error(conn, error)
    end
  end
  
  # Helper functions
  
  defp parse_id(id_string) do
    case Integer.parse(id_string) do
      {id, ""} -> {:ok, id}
      _ -> {:error, ErrorMessage.bad_request("Invalid ID format", %{id: id_string})}
    end
  end
  
  defp render_error(conn, %ErrorMessage{} = error) do
    # In a real Phoenix app:
    # conn
    # |> put_status(ErrorMessage.http_code(error))
    # |> put_view(MyApp.ErrorView)
    # |> render("error.json", error: error)
    
    # For this example, we'll just return the error
    {:error, error}
  end
end
```

## Step 4: Testing the Error Handling Flow

Let's create a module to test our error handling flow:

```elixir
defmodule MyApp.ErrorHandlingDemo do
  @moduledoc """
  Demo module to show the error handling flow
  """
  
  alias MyApp.UserController
  
  @doc """
  Run the demo with different scenarios
  """
  def run do
    # Setup mock connection and users
    admin_conn = %{assigns: %{current_user: %{id: 1, role: :admin}}}
    user_conn = %{assigns: %{current_user: %{id: 2, role: :user}}}
    
    IO.puts("\n=== Scenario 1: Admin accessing own profile ===")
    case UserController.show(admin_conn, %{"id" => "1"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 2: Admin accessing another user's profile ===")
    case UserController.show(admin_conn, %{"id" => "2"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 3: Regular user accessing own profile ===")
    case UserController.show(user_conn, %{"id" => "2"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 4: Regular user accessing admin's profile ===")
    case UserController.show(user_conn, %{"id" => "1"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 5: Invalid ID format ===")
    case UserController.show(admin_conn, %{"id" => "abc"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 6: Non-existent user ===")
    case UserController.show(admin_conn, %{"id" => "999"}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
    
    IO.puts("\n=== Scenario 7: Update with invalid role ===")
    case UserController.update(admin_conn, %{"id" => "2", "user" => %{"role" => "superuser"}}) do
      {:ok, profile} -> IO.puts("Success: #{inspect(profile)}")
      {:error, error} -> IO.puts("Error: #{error}")
    end
  end
end
```

## Step 5: Running the Demo

To run the demo, you would create a script or run it in IEx:

```elixir
# In a script or IEx session
MyApp.ErrorHandlingDemo.run()
```

This would produce output showing how different error scenarios are handled:

```
=== Scenario 1: Admin accessing own profile ===
Success: %{email: "alice@example.com", id: 1, name: "Alice", role: :admin}

=== Scenario 2: Admin accessing another user's profile ===
Success: %{email: "bob@example.com", id: 2, name: "Bob", role: :user}

=== Scenario 3: Regular user accessing own profile ===
Success: %{email: "bob@example.com", id: 2, name: "Bob", role: :user}

=== Scenario 4: Regular user accessing admin's profile ===
Error: forbidden - Not authorized to view this profile

=== Scenario 5: Invalid ID format ===
Error: bad_request - Invalid ID format
Details: 
%{id: "abc"}

=== Scenario 6: Non-existent user ===
Error: not_found - User not found
Details: 
%{user_id: 999}

=== Scenario 7: Update with invalid role ===
Error: unprocessable_entity - Invalid role
Details: 
%{allowed_roles: [:admin, :user], provided_role: "superuser"}
```

## Step 6: Logging Errors

Let's enhance our error handling with proper logging:

```elixir
defmodule MyApp.ErrorLogger do
  require Logger
  
  @doc """
  Log an error with appropriate severity based on the error code
  """
  def log_error(%ErrorMessage{} = error, context) do
    log_level = get_log_level(error.code)
    Logger.log(log_level, "[#{context}] #{error}")
    error
  end
  
  defp get_log_level(code) when code in [:internal_server_error, :service_unavailable] do
    :error
  end
  
  defp get_log_level(code) when code in [:bad_request, :unauthorized, :forbidden, :not_found] do
    :info
  end
  
  defp get_log_level(_code) do
    :warn
  end
end
```

Then update the controller to use the logger:

```elixir
defp render_error(conn, %ErrorMessage{} = error) do
  # Log the error
  MyApp.ErrorLogger.log_error(error, "UserController")
  
  # Render the error response
  # ...
end
```

## Conclusion

In this tutorial, we've built a complete error handling workflow using ErrorMessage:

1. **Domain Layer**: Used ErrorMessage to represent domain-specific errors
2. **Service Layer**: Added business logic and authorization with appropriate error messages
3. **Controller Layer**: Handled user input validation and converted errors to HTTP responses
4. **Logging**: Added contextual error logging with appropriate severity levels

This approach provides several benefits:

- **Consistent Error Structure**: All errors follow the same format
- **Rich Error Context**: Errors include detailed information to help with debugging
- **Appropriate HTTP Status Codes**: Errors map directly to HTTP status codes
- **Pattern Matching**: Easy to handle specific error types with pattern matching
- **Logging Integration**: Structured errors are easy to log and analyze

By following this pattern, you can create robust, maintainable applications with clear error handling throughout all layers of your system.
