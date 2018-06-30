defmodule Engine.Todo do
  use Ecto.Schema
  import Ecto.Changeset


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
end
