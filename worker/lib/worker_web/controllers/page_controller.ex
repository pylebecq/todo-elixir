defmodule WorkerWeb.PageController do
  use WorkerWeb, :controller

  def index(conn, _params) do
    pid = GenServer.whereis(Worker.ActivitySubscriber)
    todos = Worker.ActivitySubscriber.get_todos(pid)
    IO.inspect todos
    render(conn, "index.html", todos: todos)
  end
end
