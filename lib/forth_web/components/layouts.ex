defmodule ForthWeb.Layouts do
  use ForthWeb, :html

  embed_templates "layouts/*"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-10">
      <div class="mx-auto max-w-4xl">{render_slot(@inner_block)}</div>
    </main>
    """
  end
end
