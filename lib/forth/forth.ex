defmodule Forth do
  alias Forth.Tokenizer
  alias Forth.Executor

  def eval(code, stack \\ []) do
    with {:ok, tokens} <- Tokenizer.tokenize(code),
         {:ok, result} <- Executor.run(tokens, stack) do
      {:ok, result}
    end
  end
end
