defmodule ErrorMessageTest do
  use ExUnit.Case

  defmodule TestStruct do
    defstruct [:a]
  end

  doctest ErrorMessage

  test "string protocol works" do
    assert "not_found - couldn't find x" === to_string(ErrorMessage.not_found("couldn't find x"))
  end
end
