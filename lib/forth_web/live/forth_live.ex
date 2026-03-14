import Ecto.Query
alias Forth.Repo
alias Forth.Evaluation

defmodule ForthWeb.ForthLive do
  use ForthWeb, :live_view

  def mount(_, _, socket) do
    history =
      Repo.all(
        from e in Evaluation,
          order_by: [desc: e.id]
      )

    socket =
      socket
      |> assign(program: "", result: "", history: history)
      |> allow_upload(:forth_file,
        accept: :any,
        max_entries: 1,
        max_file_size: 100_000,
        auto_upload: true,
        progress: &handle_progress/3
      )
    {:ok, assign(socket, upload_error: nil)}
  end

  def handle_progress(:forth_file, entry, socket) do
    if entry.done? do
      try do
        [program] = consume_uploaded_entries(socket, :forth_file, fn %{path: path}, _ ->
          {:ok, File.read!(path)}
        end)

        result = eval_program(program)
        filename = entry.client_name
        eval = save_evaluation(program, result, filename)

        {:noreply,
        socket
        |> assign(result: result, upload_error: nil)
        |> Phoenix.Component.update(:history, fn h -> [eval | h] end)}
      rescue
        _ ->
          {:noreply, assign(socket, upload_error: "Invalid file encoding or binary data.")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("upload", _params, socket) do
    {:noreply, assign(socket, upload_error: nil)}
  end

  def handle_event("run", %{"program" => program}, socket) do

    result = eval_program(program)

    eval =save_evaluation(program, result, "manual")

    socket =
      socket
      |> assign(program: program, result: result)
      |> Phoenix.Component.update(:history, fn h -> [eval | h] end)

    {:noreply, socket}
  end

  defp eval_program(program) do
        case Forth.eval(program) do
          {:ok, stack} -> inspect(stack, charlists: :as_lists)
          {:error, err} -> "Error: #{err}"
        end
    end

  defp save_evaluation(program, result, source) do
    %Evaluation{}
    |> Evaluation.changeset(%{
      program: program,
      result: result,
      source: source
    })
    |> Repo.insert!()
  end
end
