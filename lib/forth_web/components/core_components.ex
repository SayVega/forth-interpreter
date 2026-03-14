defmodule ForthWeb.CoreComponents do
  use Phoenix.Component

  @doc """
  Renders a Heroicon.
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
