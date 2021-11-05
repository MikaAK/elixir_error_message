defmodule ErrorMessage.Serializer do
  @moduledoc false

  def from_struct(%ErrorMessage{code: code, message: message, details: details}) do
    %{code: code, message: message, details: ensure_json_serializable(details)}
  end

  defp ensure_json_serializable(details) when is_list(details) do
    Enum.map(details, &ensure_json_serializable/1)
  end

  defp ensure_json_serializable(%struct{} = struct_data) do
    %{
      struct: struct |> to_string |> String.replace("Elixir.", ""),
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