defmodule EngineWeb.TodoController do
  use EngineWeb, :controller

  def index(conn, _params) do
    todos = Engine.Repo.all(Engine.Todo)
    render(conn, "index.html", todos: todos)
  end

  def new(conn, _params) do
    changeset = Engine.Todo.changeset(%Engine.Todo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"todo" => todo_params}) do
    changeset = Engine.Todo.changeset(%Engine.Todo{}, todo_params)
    case Engine.Repo.insert(changeset) do
      {:ok, todo} ->
        conn
          |> put_flash(:success, "Todo ##{todo.id} created.")
          |> redirect(to: todo_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    todo = Engine.Repo.get(Engine.Todo, id)
    if todo do
      changeset = Engine.Todo.changeset(todo)
      render(conn, "edit.html", todo: todo, changeset: changeset)
    else
      conn
        |> put_status(:not_found)
        |> put_view(EngineWeb.ErrorView)
        |> render("404.html")
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Engine.Repo.get(Engine.Todo, id)
    if todo do
      changeset = Engine.Todo.changeset(todo, todo_params)
      case Engine.Repo.update(changeset) do
        {:ok, todo} ->
          conn
            |> put_flash(:success, "Todo ##{todo.id} was updated.")
            |> redirect(to: todo_path(conn, :index))
        {:error, changeset} ->
          render(conn, "edit.html", todo: todo, changeset: changeset)
      end
    else
      conn
        |> put_status(:not_found)
        |> put_view(EngineWeb.ErrorView)
        |> render("404.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Engine.Repo.get(Engine.Todo, id)
    conn = if todo do
      case Engine.Repo.delete(todo) do
        {:ok, todo} -> put_flash(conn, :success, "Todo ##{todo.id} deleted.")
        {:error, _} -> put_flash(conn, :error, "Cannot delete Todo ##{id}.")
      end
    else
      put_flash(conn, :error, "Cannot delete Todo ##{id}.")
    end

    redirect(conn, to: todo_path(conn, :index))
  end
end
