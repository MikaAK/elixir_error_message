defmodule ErrorMessage.Serializer do
  @moduledoc false

  def inspect(%ErrorMessage{code: code, message: message, details: details}) do
    details = if details !== %{} and details !== [] and not is_nil(details) do
      "\nDetails: #{Kernel.inspect(details)}"
    else
      ""
    end

    "#ErrorMessage<code: :#{code}, message: \"#{message}\">#{details}"
  end

  def to_string(%ErrorMessage{code: code, message: message, details: details}) do
    "#{code} - #{message}\nDetails: #{Kernel.inspect(details)}"
  end

  def to_jsonable_map(%ErrorMessage{code: code, message: message, details: details}) do
    %{code: code, message: message, details: ensure_json_serializable(details)}
  end

  defp ensure_json_serializable(details) when is_list(details) do
    Enum.map(details, &ensure_json_serializable/1)
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
end
