defmodule ErrorMessageTest do
  use ExUnit.Case
  doctest ErrorMessage

  test "greets the world" do
    assert ErrorMessage.hello() == :world
  end
end
