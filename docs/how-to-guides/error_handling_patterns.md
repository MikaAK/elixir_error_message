# Common Error Handling Patterns

This guide demonstrates common patterns for handling errors with the ErrorMessage library in different contexts.

## Pattern Matching on Error Codes

One of the most powerful features of ErrorMessage is the ability to pattern match on error codes:

```elixir
def process_result(result) do
  # Generally we won't be returning atoms through our
  # system but as an example of how we can handle them

  case result do
    {:ok, value} ->
      # Handle success case
      {:ok, process_value(value)}
      
    {:error, %ErrorMessage{code: :not_found}} ->
      # Handle not found specifically
      {:error, :resource_missing}
      
    {:error, %ErrorMessage{code: :unauthorized}} ->
      # Handle unauthorized specifically
      {:error, :permission_denied}
      
    {:error, %ErrorMessage{} = error} ->
      # Handle any other error
      Logger.error("Unexpected error: #{error}")
      {:error, :unexpected_error}
  end
end
```

## Using with/1 for Error Handling

The `with/1` special form in Elixir works great with ErrorMessage for handling multiple operations that might fail:

```elixir
def create_order(user_id, product_id, quantity) do
  with {:ok, user} <- find_user(user_id),
       {:ok, product} <- find_product(product_id),
       {:ok, _} <- check_inventory(product, quantity),
       {:ok, order} <- create_order_record(user, product, quantity) do
    {:ok, order}
  else
    {:error, %ErrorMessage{code: :not_found, details: %{user_id: _}}} ->
      {:error, ErrorMessage.bad_request("Invalid user", %{user_id: user_id})}
      
    {:error, %ErrorMessage{code: :not_found, details: %{product_id: _}}} ->
      {:error, ErrorMessage.bad_request("Invalid product", %{product_id: product_id})}
      
    {:error, error} ->
      # Pass through any other errors
      {:error, error}
  end
end
```

## Converting Other Error Types to ErrorMessage

Often you'll need to convert errors from other libraries to ErrorMessage format:

```elixir
def handle_ecto_errors(changeset) do
  errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end)
  
  ErrorMessage.unprocessable_entity("Validation failed", errors)
end

def handle_file_errors(file_path) do
  case File.read(file_path) do
    {:ok, content} ->
      {:ok, content}
      
    {:error, :enoent} ->
      {:error, ErrorMessage.not_found("File not found", %{path: file_path})}
      
    {:error, :eacces} ->
      {:error, ErrorMessage.forbidden("Permission denied", %{path: file_path})}
      
    {:error, reason} ->
      {:error, ErrorMessage.internal_server_error("File error", %{reason: reason, path: file_path})}
  end
end
```

## Error Handling in GenServers

ErrorMessage works well in GenServer implementations:

```elixir
defmodule MyApp.UserManager do
  use GenServer
  
  # Client API
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def get_user(id) do
    GenServer.call(__MODULE__, {:get_user, id})
  end
  
  # Server Callbacks
  
  def init(opts) do
    {:ok, %{users: opts[:initial_users] || %{}}}
  end
  
  def handle_call({:get_user, id}, _from, state) do
    case Map.get(state.users, id) do
      nil ->
        {:reply, {:error, ErrorMessage.not_found("User not found", %{user_id: id})}, state}
        
      user ->
        {:reply, {:ok, user}, state}
    end
  end
end
```

## Composing Error Handlers

You can create helper functions to handle common error patterns:

```elixir
defmodule MyApp.ErrorHelpers do
  require Logger
  
  def with_logging(result, context) do
    case result do
      {:ok, _} = success ->
        success
        
      {:error, %ErrorMessage{} = error} ->
        Logger.error("[#{context}] #{error}")
        {:error, error}
    end
  end
  
  def with_fallback(result, fallback_fn) do
    case result do
      {:ok, _} = success ->
        success
        
      {:error, %ErrorMessage{code: :not_found}} ->
        fallback_fn.()
        
      {:error, _} = error ->
        error
    end
  end
  
  def with_retry(operation, retry_count \\ 3) do
    retry_with_count(operation, retry_count)
  end
  
  defp retry_with_count(operation, count) when count > 0 do
    case operation.() do
      {:ok, _} = success ->
        success
        
      {:error, %ErrorMessage{code: code} = error} when code in [:service_unavailable, :gateway_timeout] ->
        # Only retry on certain errors
        Process.sleep(100)
        retry_with_count(operation, count - 1)
        
      {:error, _} = error ->
        error
    end
  end
  
  defp retry_with_count(_operation, 0) do
    {:error, ErrorMessage.service_unavailable("Operation failed after multiple retries")}
  end
end
```

Usage:

```elixir
import MyApp.ErrorHelpers

def process_user(id) do
  with_logging(
    with_fallback(
      UserRepository.find_user(id),
      fn -> UserRepository.create_default_user(id) end
    ),
    "UserProcessing"
  )
end

def fetch_remote_data(url) do
  with_retry(fn -> ApiClient.get(url) end)
end
```

## Handling Errors in Concurrent Operations

When working with concurrent operations, you can collect and process errors:

```elixir
def process_items(items) do
  items
  |> Enum.map(fn item ->
    Task.async(fn -> process_item(item) end)
  end)
  |> Task.await_many()
  |> Enum.split_with(fn
    {:ok, _} -> true
    {:error, _} -> false
  end)
  |> case do
    {successes, []} ->
      # All operations succeeded
      {:ok, Enum.map(successes, fn {:ok, result} -> result end)}
      
    {_, errors} ->
      # Some operations failed
      error_details = Enum.map(errors, fn {:error, error} -> 
        %{item_id: error.details.item_id, reason: error.message}
      end)
      
      {:error, ErrorMessage.multi_status("Some operations failed", %{errors: error_details})}
  end
end
```

These patterns should help you effectively use ErrorMessage in various scenarios throughout your application.
