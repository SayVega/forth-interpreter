defmodule Forth.Tokenizer do
  def tokenize(code) when is_binary(code) do
    code
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&parse_token/1)
    |> wrap_result()
  end

  defp parse_token(token) do
    case Integer.parse(token) do
      {number, ""} ->
        number

      _ ->
        String.to_atom(token)
    end
  end

  defp wrap_result(tokens) do
    {:ok, tokens}
  end
end
