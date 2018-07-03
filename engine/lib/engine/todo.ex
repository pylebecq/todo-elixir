defmodule Engine.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]


  schema "todos" do
    field :done, :boolean, default: false
    field :done_at, :utc_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs \\ %{}) do
    todo
    |> cast(attrs, [:title, :done, :done_at])
    |> validate_required([:title, :done])
    |> validate_length(:title, min: 1)
    |> validate_length(:title, max: 255)
  end

  def get_todos do
    query = from n in Engine.Todo,
      select: %Engine.Todo{id: n.id, title: n.title, done: n.done, done_at: n.done_at}

    query
    |> Engine.Repo.all
    |> Enum.reduce(%{}, fn todo, acc -> 
      Map.put(acc, String.to_atom("#{todo.id}"), todo)
    end)
  end
end
