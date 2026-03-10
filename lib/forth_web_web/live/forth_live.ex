defmodule ForthWebWeb.ForthLive do
  use ForthWebWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
      assign(socket,
        program: "",
        result: "",
        history: []
      )}
  end

  def handle_event("run", %{"program" => program}, socket) do
    result =
      case Forth.eval(program) do
        {:ok, stack} -> inspect(stack)
        {:error, err} -> "Error: #{err}"
      end

    history = [{program, result} | socket.assigns.history]

    {:noreply,
      assign(socket,
        program: program,
        result: result,
        history: history
      )}
  end
end
