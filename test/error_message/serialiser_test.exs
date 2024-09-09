defmodule ErrorMessage.SerializerTest do
  use ExUnit.Case

  describe "&to_jsonable_map/1" do
    test "serializes anonymous function correctly" do
      anon_fun = fn x -> x + 1 end
      error_msg = ErrorMessage.not_found("anonymous function serialization", anon_fun)

      serialized = ErrorMessage.Serializer.to_jsonable_map(error_msg)

      assert serialized.details === %{
               module: "Elixir.ErrorMessage.SerializerTest",
               function:
                 "-test &to_jsonable_map/1 serializes anonymous function correctly/1-fun-0-",
               arity: 1
             }
    end

    test "serializes named function correctly" do
      named_fun = &String.length/1
      error_msg = ErrorMessage.not_found("named function serialization", named_fun)

      serialized = ErrorMessage.Serializer.to_jsonable_map(error_msg)

      assert serialized.details === %{
               module: "Elixir.String",
               function: "length",
               arity: 1
             }
    end

    test "serializes Erlang function correctly" do
      erlang_fun = &:erlang.self/0
      error_msg = ErrorMessage.not_found("Erlang function serialization", erlang_fun)

      serialized = ErrorMessage.Serializer.to_jsonable_map(error_msg)

      assert serialized.details === %{
               module: "erlang",
               function: "self",
               arity: 0
             }
    end
  end
end
