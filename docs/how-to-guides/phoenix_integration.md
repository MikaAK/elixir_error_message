# How to Integrate ErrorMessage with Phoenix

This guide demonstrates how to effectively use ErrorMessage in a Phoenix application to handle errors consistently across your API.

## Setting Up Error Handling in Controllers

Create a helper module or function to handle error responses consistently:

```elixir
defmodule MyApp.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Renders an error response using the ErrorMessage struct
  """
  def render_error(conn, %ErrorMessage{} = error) do
    conn
    |> put_status(ErrorMessage.http_code(error))
    |> put_view(MyApp.ErrorView)
    |> render("error.json", error: error)
  end
end
```

## Creating an Error View

In your Phoenix application, create or update your error view to handle ErrorMessage structs:

```elixir
defmodule MyApp.ErrorView do
  use MyApp, :view

  @doc """
  Renders an error message from an ErrorMessage struct
  """
  def render("error.json", %{error: error}) do
    ErrorMessage.to_jsonable_map(error)
  end

  # Keep your existing error templates
  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
```

## Using in Controllers

Now you can use ErrorMessage in your controllers:

```elixir
defmodule MyApp.UserController do
  use MyApp, :controller
  import MyApp.ErrorHandler

  def show(conn, %{"id" => id}) do
    case MyApp.Accounts.get_user(id) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
        
      {:error, %ErrorMessage{} = error} ->
        render_error(conn, error)
    end
  end
  
  def create(conn, %{"user" => user_params}) do
    case MyApp.Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)
        
      {:error, %ErrorMessage{} = error} ->
        render_error(conn, error)
    end
  end
end
```

## Creating a Fallback Controller

For more advanced error handling, you can create a fallback controller:

```elixir
defmodule MyApp.FallbackController do
  use Phoenix.Controller
  import MyApp.ErrorHandler

  def call(conn, {:error, %ErrorMessage{} = error}) do
    render_error(conn, error)
  end

  # Handle other error types
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    # Convert Ecto.Changeset errors to ErrorMessage
    errors = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    error = ErrorMessage.unprocessable_entity("Invalid parameters", errors)
    
    render_error(conn, error)
  end
  
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
```

Then in your controller:

```elixir
defmodule MyApp.UserController do
  use MyApp, :controller
  
  action_fallback MyApp.FallbackController
  
  def show(conn, %{"id" => id}) do
    with {:ok, user} <- MyApp.Accounts.get_user(id) do
      render(conn, "show.json", user: user)
    end
  end
end
```

## Adding Request ID to Error Responses

ErrorMessage automatically includes the request ID in the error response if it's available in the Logger metadata. To ensure this works:

1. Make sure you have the RequestId plug enabled in your endpoint:

```elixir
defmodule MyApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app
  
  plug Plug.RequestId
  # ...
end
```

2. Ensure Logger is configured to include the request_id in metadata:

```elixir
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
```

With this setup, all your API error responses will automatically include the request ID, making it easier to correlate errors with specific requests in your logs.
