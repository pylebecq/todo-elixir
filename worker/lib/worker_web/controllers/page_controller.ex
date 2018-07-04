defmodule WorkerWeb.PageController do
  use WorkerWeb, :controller

  def index(conn, _params) do
    todos = Worker.TodoStorage.get_all()
    render(conn, "index.html", todos: todos)
  end
end
