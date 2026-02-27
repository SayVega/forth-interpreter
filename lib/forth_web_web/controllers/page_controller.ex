defmodule ForthWebWeb.PageController do
  use ForthWebWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
