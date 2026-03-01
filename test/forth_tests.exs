defmodule ForthTest do
  use ExUnit.Case
  doctest Forth

  defp eval(code), do: Forth.eval(code, [])
  defp eval(code, initial_stack), do: Forth.eval(code, initial_stack)

  describe "basic number parsing" do
    test "parses single positive integer" do
      assert eval("5") == {:ok, [5]}
    end

    test "parses single negative integer" do
      assert eval("-5") == {:ok, [-5]}
    end
  end
end