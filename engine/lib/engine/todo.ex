defmodule Engine.Todo do
  use Ecto.Schema
  import Ecto.Changeset


  schema "todos" do
    field :created_at, :utc_datetime
    field :done, :boolean, default: false
    field :done_at, :utc_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :done, :created_at, :done_at])
    |> validate_required([:title, :done, :created_at])
    |> validate_length(:title, min: 1)
    |> validate_length(:title, max: 255)
  end
end
