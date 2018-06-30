defmodule Engine.Repo.Migrations.AlterTodosRemoveCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      remove :created_at
    end
  end
end
