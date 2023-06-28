defmodule ErrorMessage.Serializer do
  require Logger

  @moduledoc false

  def to_string(%ErrorMessage{code: code, message: message, details: details})
      when details === [] or is_nil(details) or details === %{} do
    "#{code} - #{message}"
  end

  def to_string(%ErrorMessage{code: code, message: message, details: details}) do
    "#{code} - #{message}\nDetails: \n#{inspect(details, pretty: true)}"
  end

  def to_jsonable_map(%ErrorMessage{code: code, message: message, details: details}) do
    if Logger.metadata[:request_id] do
      %{
        code: code,
        message: message,
        request_id: Logger.metadata[:request_id],
        details: ensure_json_serializable(details)
      }
    else
      %{
        code: code,
        message: message,
        details: ensure_json_serializable(details)
      }
    end
  end

  defp ensure_json_serializable(pid) when is_pid(pid) do
    pid_string = inspect(pid)

    if local_pid?(pid) do
      case Process.info(pid, :registered_name) do
        nil -> pid_string
        {:registered_name, []} -> pid_string
        {:registered_name, registered_name} -> "#{pid_string}__#{registered_name}"
      end
    else
      pid_string
    end
  end

  defp ensure_json_serializable(details) when is_list(details) do
    Enum.map(details, &ensure_json_serializable/1)
  end

  defp ensure_json_serializable(%Date{} = date) do
    Date.to_iso8601(date)
  end

  defp ensure_json_serializable(%Time{} = time) do
    Time.to_iso8601(time)
  end

  defp ensure_json_serializable(%DateTime{} = date_time) do
    DateTime.to_iso8601(date_time)
  end

  defp ensure_json_serializable(%NaiveDateTime{} = naive_date_time) do
    NaiveDateTime.to_iso8601(naive_date_time)
  end

  defp ensure_json_serializable(%struct{} = struct_data) do
    %{
      struct: struct |> Kernel.to_string |> String.replace("Elixir.", ""),
      data: struct_data |> Map.from_struct() |> ensure_json_serializable
    }
  end

  defp ensure_json_serializable(details) when is_map(details) do
    Enum.into(details, %{}, fn {key, value} ->
      {key, ensure_json_serializable(value)}
    end)
  end

  defp ensure_json_serializable(details) when is_tuple(details) do
    details |> Tuple.to_list |> ensure_json_serializable
  end

  defp ensure_json_serializable(value) do
    value
  end

  defp local_pid?(pid) do
    node(pid) === node()
  end
end
