defmodule Forth.Executor do
  def run(tokens, stack \\ []) when is_list(tokens) do
    state = %{
      stack: stack,
      defining: false,
      dictionary: %{},
      current_word: nil,
      current_definition: [],
    }
    result =
      Enum.reduce_while(tokens, {:ok, state}, fn token, {:ok, state} ->
        case process_token(token, state) do
          {:ok, new_state} ->
            {:cont, {:ok, new_state}}

          {:error, reason} ->
            {:halt, {:error, reason}}
        end
      end)

    case result do
      {:ok, %{defining: true}} -> {:error, "unterminated definition"}
      {:ok, %{stack: stack}} -> {:ok, Enum.reverse(stack)}
      error -> error
    end
  end

## Word definition

  defp process_token(:":", %{defining: true}) do
  {:error, "already defining a word"}
  end

  defp process_token(:":", state) do
    {:ok, %{state | defining: true, current_word: :expect_name, current_definition: []}}
  end

  defp process_token(token, %{defining: true, current_word: :expect_name} = _state)
  when is_integer(token) or token == :";" do
    {:error, "invalid word definition"}
  end

  defp process_token(token, %{defining: true, current_word: :expect_name} = state) do
    {:ok, %{state | current_word: token}}
  end

  defp process_token(token, %{defining: true, current_definition: defn, current_word: word, dictionary: dictionary} = state)
    when  token != :";" and word != :expect_name do
      cond do
      is_integer(token) ->
        {:ok, %{state | current_definition: [token | defn]}}

      Map.has_key?(dictionary, token) or
      token in [:+, :-, :*, :/, :MOD, :DUP, :DROP, :OVER, :SWAP, :ROT, :NIP, :TUCK,
                :"2DUP", :"2DROP", :"2SWAP", :"2OVER", :>, :<, :=, :AND, :OR, :INVERT, :NOT] ->
        {:ok, %{state | current_definition: [token | defn]}}

      true ->
        {:error, "unknown word: #{String.downcase(Atom.to_string(token))}"}
    end
  end

  defp process_token(:";", %{defining: true, current_word: word, current_definition: defn, dictionary: dictionary} = state)
    when is_atom(word) do
      new_dictionary = Map.put(dictionary, word, Enum.reverse(defn))
      {:ok, %{state | defining: false, dictionary: new_dictionary, current_word: nil, current_definition: []}}
  end

## Pushing numbers

  defp process_token(number, %{stack: stack} = state) when is_integer(number) do
    {:ok, %{state | stack: [number | stack]}}
  end

## Arithmetic operations

  defp process_token(:+, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b + a | rest]}}
  end

  defp process_token(:+, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:-, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b - a | rest]}}
  end

  defp process_token(:-, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:*, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b * a | rest]}}
  end

  defp process_token(:*, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:/, %{stack: [0, _b | _rest]} = _state) do
    {:error, "division by zero"}
  end

  defp process_token(:/, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [div(b, a) | rest]}}
  end

  defp process_token(:/, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:MOD, %{stack: [0, _b | _rest]} = _state) do
    {:error, "division by zero"}
  end

  defp process_token(:MOD, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [rem(b, a) | rest]}}
  end

  defp process_token(:MOD, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

## Stack manipulation

  defp process_token(:DUP, %{stack: [a | rest]} = state) do
    {:ok, %{state | stack: [a, a | rest]}}
  end

  defp process_token(:DUP, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:DROP, %{stack: [_a | rest]} = state) do
    {:ok, %{state | stack: rest}}
  end

  defp process_token(:DROP, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:OVER, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b, a, b | rest]}}
  end

  defp process_token(:OVER, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:SWAP, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [b, a | rest]}}
  end

  defp process_token(:SWAP, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:ROT, %{stack: [a, b, c | rest]} = state) do
    {:ok, %{state | stack: [c, a, b | rest]}}
  end

  defp process_token(:ROT, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:NIP, %{stack: [a, _b | rest]} = state) do
    {:ok, %{state | stack: [a | rest]}}
  end

  defp process_token(:NIP, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:TUCK, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [a, b, a | rest]}}
  end

  defp process_token(:TUCK, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:"2DUP", %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [a, b, a, b | rest]}}
  end

  defp process_token(:"2DUP", %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:"2DROP", %{stack: [_a, _b | rest]} = state) do
    {:ok, %{state | stack: rest}}
  end

  defp process_token(:"2DROP", %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:"2SWAP", %{stack: [a, b, c, d | rest]} = state) do
    {:ok, %{state | stack: [c, d, a, b | rest]}}
  end

  defp process_token(:"2SWAP", %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:"2OVER", %{stack: [a, b, c, d | rest]} = state) do
    {:ok, %{state | stack: [c, d, a, b, c, d | rest]}}
  end

  defp process_token(:"2OVER", %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

## Comparison operations

  defp process_token(:>, %{stack: [a, b | rest]} = state) do
    value = if b > a, do: -1, else: 0
    {:ok, %{state | stack: [value | rest]}}
  end

  defp process_token(:>, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

    defp process_token(:<, %{stack: [a, b | rest]} = state) do
    value = if b < a, do: -1, else: 0
    {:ok, %{state | stack: [value | rest]}}
  end

  defp process_token(:<, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:=, %{stack: [a, b | rest]} = state) do
    value = if b == a, do: -1, else: 0
    {:ok, %{state | stack: [value | rest]}}
  end

  defp process_token(:=, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

## Bitwise operations

  defp process_token(:AND, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [Bitwise.band(b, a) | rest]}}
  end

  defp process_token(:AND, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:OR, %{stack: [a, b | rest]} = state) do
    {:ok, %{state | stack: [Bitwise.bor(b, a) | rest]}}
  end

  defp process_token(:OR, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

  defp process_token(:INVERT, %{stack: [a | rest]} = state) do
    {:ok, %{state | stack: [Bitwise.bnot(a) | rest]}}
  end

  defp process_token(:INVERT, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

## Boolean operations

  defp process_token(:NOT, %{stack: [a | rest]} = state) do
    value = if a == 0, do: -1, else: 0
    {:ok, %{state | stack: [value | rest]}}
  end

  defp process_token(:NOT, %{stack: _stack} = _state) do
    {:error, "stack underflow"}
  end

## Dictionary execution

  defp process_token(token, %{dictionary: dictionary} = state) when is_atom(token) do
    case Map.get(dictionary, token) do
      nil ->
        {:error, "unknown word: #{String.downcase(Atom.to_string(token))}"}

      definition ->
        Enum.reduce_while(definition, {:ok, state}, fn def_token, {:ok, state} ->
          case process_token(def_token, state) do
            {:ok, new_state} -> {:cont, {:ok, new_state}}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
    end
  end

## Undefined words

  defp process_token(_unknown, %{stack: _stack}) do
    {:error, "undefined word"}
  end
end
