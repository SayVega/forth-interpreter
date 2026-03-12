defmodule ForthWebWeb.ForthLive do
  use ForthWebWeb, :live_view

  def mount(_, _, socket) do
    socket =
      socket
      |> assign(program: "", result: "")
      |> allow_upload(:forth_file,
          accept: :any,
          max_entries: 1,
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

      {:noreply, assign(socket, result: result)}
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

    {:noreply,
    assign(socket,
      program: program,
      result: result
    )}
  end
end
