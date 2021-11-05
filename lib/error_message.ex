defmodule ErrorMessage do
  @moduledoc """
  This module has error generation functions, each atom passed into
  `error_message_defs` is created to the format of `&error_message/2` and
  `&error_message/3` with the code pre-passed in

  *Note: `error_message_defs` is a gross macro, but I can't think of a
  better way that doesn't involve `n * 7` lines of code for every code*

  ### Example

    error_message_defs(:not_found)

  now we can do

    ErrorMessage.not_found("Something Happened?", %{reason: ...})
    ErrorMessage.not_found("Something Happened?")
  """

  @enforce_keys [:code, :message]
  defstruct [:code, :message, :details]

  @type t ::
          %ErrorMessage{code: atom, message: String.t()}
          | %ErrorMessage{code: atom, message: String.t(), details: any}

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
    Function to create #{error_code} error message
    """
    def unquote(error_code)(message) do
      %ErrorMessage{code: unquote(error_code), message: message}
    end

    def unquote(error_code)(message, details) do
      %ErrorMessage{code: unquote(error_code), message: message, details: details}
    end
  end
end
