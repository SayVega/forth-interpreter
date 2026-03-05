defmodule Forth.Executor do
  def run(tokens, stack \\ []) when is_list(tokens) do
    state = %{
      stack: stack,
      defining: false,
      dictionary: %{},
      current_word: nil,
      current_definition: [],
    }

    Enum.reduce_while(tokens, {:ok, state}, fn token, {:ok, state} ->
      case process_token(token, state) do
        {:ok, new_state} ->
          {:cont, {:ok, new_state}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)

    case result do
      {:ok, %{stack: stack}} -> {:ok, stack}
      error -> error
    end
  end

  defp process_token(number, %{stack: stack} = state) when is_integer(number) do
    {:ok, %{state | stack: [number | stack]}}
  end

  defp process_token(:+, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b + a | rest]}}
  end

  defp process_token(:+, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:-, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b - a | rest]}}
  end

  defp process_token(:-, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:*, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b * a | rest]}}
  end

  defp process_token(:*, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:/, %{stack: [0, _b | _rest]} = _state) do
    {:error, :division_by_zero}
  end

  defp process_token(:/, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [div(b, a) | rest]}}
  end

  defp process_token(:/, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:MOD, %{stack: [0, _b | _rest]} = _state) do
    {:error, :division_by_zero}
  end

  defp process_token(:MOD, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [rem(b, a) | rest]}}
  end

  defp process_token(:MOD, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:DUP, %{stack: [a | rest]} = state) do
    {:ok, %{state | stack: [a, a | rest]}}
  end

  defp process_token(:DUP, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:DROP, %{stack: [_a | rest]} = state) do
    {:ok, %{state | stack: rest}}
  end

  defp process_token(:DROP, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:OVER, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b, a, b | rest]}}
  end

  defp process_token(:OVER, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:SWAP, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b, a | rest]}}
  end

  defp process_token(:SWAP, %{stack: _stack} = _state) do
    {:error, :stack_underflow}
  end

  defp process_token(:":", state) do
    {:ok, %{state | defining: true, current_word: :expect_name, current_definition: []}}
  end

  defp process_token(token, %{defining: true, current_word: :expect_name} = state) do
    {:ok, %{state | current_word: token}}
  end

  defp process_token(token, %{defining: true, current_word: word, current_definition: defn} = state)
    when is_atom(word) and token != :";" do
      {:ok, %{state | current_definition: defn ++ [token]}}
  end

  defp process_token(:";", %{defining: true, current_word: word, current_definition: defn, dictionary: dictionary} = state)
    when is_atom(word) do
      new_dictionary = Map.put(dictionary, word, defn)

      {:ok, %{state | defining: false,dictionary: new_dictionary, current_word: nil, current_definition: []}}
  end

  defp process_token(_unknown, %{stack: _stack}) do
    {:error, :unknown_token}
  end
end
