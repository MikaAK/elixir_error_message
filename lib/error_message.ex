defmodule ErrorMessage do
  @moduledoc "#{File.read!("./README.md")}"

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
