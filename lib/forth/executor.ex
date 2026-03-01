defmodule Forth.Executor do
  def run(tokens, stack \\ []) when is_list(tokens) do
    Enum.reduce_while(tokens, {:ok, stack}, fn token, {:ok, stack} ->
      case process_token(token, stack) do
        {:ok, new_stack} ->
          {:cont, {:ok, new_stack}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  defp process_token(number, stack) when is_integer(number) do
    {:ok, [number | stack]}
  end

  defp process_token(:+, [a, b | rest]) do
    {:ok, [b + a | rest]}
  end

  defp process_token(:+, _stack) do
    {:error, :stack_underflow}
  end

  defp process_token(_unknown, _stack) do
    {:error, :unknown_token}
  end
end
