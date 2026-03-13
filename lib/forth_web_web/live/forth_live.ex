import Ecto.Query
alias ForthWeb.Repo
alias ForthWeb.ForthWeb.Evaluations.Evaluation

defmodule ForthWebWeb.ForthLive do
  use ForthWebWeb, :live_view

  def mount(_, _, socket) do
    history =
  Repo.all(
    from e in Evaluation,
      order_by: [desc: e.inserted_at]
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

    {:ok, socket}
  end

  def handle_progress(:forth_file, entry, socket) do
    if entry.done? do
      [program] =
        consume_uploaded_entries(socket, :forth_file, fn %{path: path}, _ ->
          {:ok, File.read!(path)}
        end)

      result =
        case Forth.eval(program) do
          {:ok, stack} -> inspect(stack, charlists: :as_lists)
          {:error, err} -> "Error: #{err}"
        end

      filename = entry.client_name
      eval =
        %Evaluation{}
        |> Evaluation.changeset(%{
          program: program,
          result: result,
          source: filename
        })
        |> Repo.insert!()

      socket =
        socket
        |> assign(result: result)
        |> Phoenix.Component.update(:history, fn h -> [eval | h] end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("upload", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("run", %{"program" => program}, socket) do
    result =
      case Forth.eval(program) do
        {:ok, stack} -> inspect(stack, charlists: :as_lists)
        {:error, err} ->"Error: #{err}"
      end

  {:ok, eval} =
    %Evaluation{}
    |> Evaluation.changeset(%{
      program: program,
      result: result,
      source: "manual"
    })
    |> Repo.insert()

  socket =
    socket
    |> assign(program: program, result: result)
    |> Phoenix.Component.update(:history, fn h -> [eval | h] end)

  {:noreply, socket}
  end
end
