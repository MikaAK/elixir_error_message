defmodule ErrorMessage do
  @moduledoc """
  ErrorMessage
  ===

  This library exists to simplify error systems in a code base
  and allow for a simple unified experience when using and reading
  error messages around the code base

  This creates one standard, that all errors should fit into the context
  of HTTP error codes, if they don't `:internal_server_error` should
  be used and you can use the message and details to provide a further
  level of depth

  ### Example

  ```elixir
  iex> id = 1
  iex> ErrorMessage.not_found("no user with id \#{id}", %{user_id: id})
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

  ## Why is this important
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

  ## Usage with Phoenix
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

  ## Usage with Logger
  Ontop of being useful for Phoenix we can also find some good use from this
  system and Logger, since `ErrorMessage` implements `String.Chars` protocol

  ```elixir
  case do_thing() do
    {:ok, value} -> {:ok, do_other_thing(value)}
    {:error, e} = res ->
      Logger.error("[MyModule] \#{to_string(e)}")

      res
  end

  ```
  """

  @enforce_keys [:code, :message]
  defstruct [:code, :message, :details]

  @type t ::
          %ErrorMessage{code: atom, message: String.t()}
          | %ErrorMessage{code: atom, message: String.t(), details: any}

  @type t_map ::
          %{code: atom, message: String.t()}
          | %{code: atom, message: String.t(), details: any}


  @http_error_codes ~w(
    multiple_choices
    moved_permanently
    found
    see_other
    not_modified
    use_proxy
    switch_proxy
    temporary_redirect
    permanent_redirect
    bad_request
    unauthorized
    payment_required
    forbidden
    not_found
    method_not_allowed
    not_acceptable
    proxy_authentication_required
    request_timeout
    conflict
    gone
    length_required
    precondition_failed
    request_entity_too_large
    request_uri_too_long
    unsupported_media_type
    requested_range_not_satisfiable
    expectation_failed
    im_a_teapot
    misdirected_request
    unprocessable_entity
    locked
    failed_dependency
    too_early
    upgrade_required
    precondition_required
    too_many_requests
    request_header_fields_too_large
    unavailable_for_legal_reasons
    internal_server_error
    not_implemented
    bad_gateway
    service_unavailable
    gateway_timeout
    http_version_not_supported
    variant_also_negotiates
    insufficient_storage
    loop_detected
    not_extended
    network_authentication_required
  )a

  for error_code <- @http_error_codes do
    @spec unquote(error_code)(message :: String.t) :: t
    @spec unquote(error_code)(message :: String.t, details :: any) :: t
    @doc """
    Create #{error_code} error message

    ## Example

      iex>
    """
    def unquote(error_code)(message) do
      %ErrorMessage{code: unquote(error_code), message: message}
    end

    def unquote(error_code)(message, details) do
      %ErrorMessage{code: unquote(error_code), message: message, details: details}
    end
  end

  @spec to_string(error_message :: t) :: String.t
  @doc """
  Converts an `%ErrorMessage{}` struct to a string formatted error message

    ## Example

      iex>
  """
  defdelegate to_string(error_message), to: ErrorMessage.Serializer, as: :to_error_string

  @spec to_map(error_message :: t) :: t_map
  @doc """
  Converts an `%ErrorMessage{}` struct to a map and makes sure that the
  contents of the details map can be converted to json

    ## Example

      iex>
  """
  defdelegate to_map(error_message), to: ErrorMessage.Serializer

  @spec inspect(error_message :: t) :: String.t
  @doc """
  Converts an `%ErrorMessage{}` struct into an inspectable version
  """
  defdelegate inspect(error_message), to: ErrorMessage.Serializer, as: :inspect_error

  defimpl String.Chars do
    def to_string(%ErrorMessage{} = e) do
      ErrorMessage.to_string(e)
    end
  end

  defimpl Inspect do
    def inspect(%ErrorMessage{} = e, _) do
      ErrorMessage.inspect(e)
    end
  end
end
