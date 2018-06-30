defmodule EngineWeb.TodoController do
  use EngineWeb, :controller

  def index(conn, _params) do
    todos = Engine.Repo.all(Engine.Todo)
    render conn, "index.html", todos: todos
  end

  def new(conn, _params) do
    changeset = Engine.Todo.changeset(%Engine.Todo{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"todo" => todo_params}) do
    changeset = Engine.Todo.changeset(%Engine.Todo{}, todo_params)
    case Engine.Repo.insert(changeset) do
      {:ok, todo} ->
        conn
          |> put_flash(:success, "#{todo.id} created.")
          |> redirect(to: todo_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
