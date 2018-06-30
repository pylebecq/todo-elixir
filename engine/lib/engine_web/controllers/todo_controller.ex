defmodule EngineWeb.TodoController do
  use EngineWeb, :controller

  def index(conn, _params) do
    todos = Engine.Repo.all(Engine.Todo)
    render conn, "index.html", todos: todos
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, params) do
    redirect conn, to: "/"
  end
end
