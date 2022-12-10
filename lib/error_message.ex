defmodule ErrorMessage do
  @moduledoc "#{File.read!("./README.md")}"

  if Enum.any?(Application.loaded_applications(), fn {dep_name, _, _} -> dep_name === :jason end) do
    @derive Jason.Encoder
  end

  @enforce_keys [:code, :message]
  defstruct [:code, :message, :details]

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

  @type t :: %ErrorMessage{code: code, message: String.t(), details: any()}
  @type t(details) :: %ErrorMessage{code: code, message: String.t(), details: details}

  @type t_map :: %{code: code, message: String.t(), details: any(), request_id: String.t()} |
                 %{code: code, message: String.t(), details: any()}

  @type t_map(details) :: %{code: code, message: String.t(), details: details, request_id: String.t()} |
                          %{code: code, message: String.t(), details: details}

  @type t_res :: {:ok, term} | {:error, t}
  @type t_res(result_type) :: {:ok, result_type} | {:error, t}
  @type t_res(result_type, details_type) :: {:ok, result_type} | {:error, t(details_type)}

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
    Create #{error_code} error message for status code #{Plug.Conn.Status.code(error_code)}

    ## Example

        iex> ErrorMessage.#{error_code}("error message")
        %ErrorMessage{code: :#{error_code}, message: "error message"}
    """
    def unquote(error_code)(message) do
      %ErrorMessage{code: unquote(error_code), message: message}
    end

    @doc """
    Create #{error_code} error message for status code #{Plug.Conn.Status.code(error_code)} with a details item which is
    passed in as the details key under the `ErrorMessage` struct

    ## Example

        iex> ErrorMessage.#{error_code}("error message", %{item: 1234})
        %ErrorMessage{code: :#{error_code}, message: "error message", details: %{item: 1234}}
    """
    def unquote(error_code)(message, details) do
      %ErrorMessage{code: unquote(error_code), message: message, details: details}
    end
  end

  @spec to_string(error_message :: t) :: String.t
  @doc """
  Converts an `%ErrorMessage{}` struct to a string formatted error message

    ## Example

        iex> ErrorMessage.to_string(ErrorMessage.internal_server_error("Something bad happened", %{result: :unknown}))
        "internal_server_error - Something bad happened\\nDetails: \\n%{result: :unknown}"
  """
  defdelegate to_string(error_message), to: ErrorMessage.Serializer

  @spec to_jsonable_map(error_message :: t) :: t_map
  @doc """
  Converts an `%ErrorMessage{}` struct to a map and makes sure that the
  contents of the details map can be converted to json

    ## Example

        iex> ErrorMessage.to_jsonable_map(ErrorMessage.not_found("couldn't find user", %{user_id: "as21fasdfJ"}))
        %{code: :not_found, message: "couldn't find user", details: %{user_id: "as21fasdfJ"}}

        iex> error = ErrorMessage.im_a_teapot("teapot", %{
        ...>   user: %{health: {:alive, 500}},
        ...>   test: %TestStruct{a: [Date.new!(2020, 1, 10)]}
        ...> })
        iex> ErrorMessage.to_jsonable_map(error)
        %{
          code: :im_a_teapot,
          message: "teapot",
          details: %{
            user: %{health: [:alive, 500]},
            test: %{struct: "ErrorMessageTest.TestStruct", data: %{a: ["2020-01-10"]}}
          }
        }
  """
  defdelegate to_jsonable_map(error_message), to: ErrorMessage.Serializer

  @spec http_code_reason_atom(error_code :: non_neg_integer()) :: code
  @doc """
  Returns the http reason as an atom for the http error code

  ## Example

      iex> ErrorMessage.http_code_reason_atom(500)
      :internal_server_error
  """
  defdelegate http_code_reason_atom(error_code), to: Plug.Conn.Status, as: :reason_atom

  @spec http_code(error_code :: code) :: non_neg_integer()
  @spec http_code(error_message :: t) :: non_neg_integer()
  @doc """
  Returns the http code for an error message or error code atom

  ## Example

      iex> ErrorMessage.http_code(:internal_server_error)
      500

      iex> ErrorMessage.http_code(ErrorMessage.not_found("some_message"))
      404
  """
  def http_code(%ErrorMessage{code: code}), do: http_code(code)

  defdelegate http_code(error_code), to: Plug.Conn.Status, as: :code

  defimpl String.Chars do
    def to_string(%ErrorMessage{} = e) do
      ErrorMessage.to_string(e)
    end
  end
end
