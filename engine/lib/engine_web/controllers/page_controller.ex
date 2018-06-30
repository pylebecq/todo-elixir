defmodule EngineWeb.PageController do
  use EngineWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
