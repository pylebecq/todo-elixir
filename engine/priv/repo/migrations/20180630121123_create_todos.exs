defmodule Engine.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :done, :boolean, default: false, null: false
      add :created_at, :utc_datetime
      add :done_at, :utc_datetime

      timestamps()
    end

  end
end
