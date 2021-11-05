defmodule ErrorMessageTest do
  use ExUnit.Case

  defmodule TestStruct do
    defstruct [:a]
  end

  doctest ErrorMessage
end
