defmodule Forth.Repo.Migrations.CreateEvaluations do
  use Ecto.Migration

  def change do
    create table(:evaluations) do
      add :program, :text, null: false
      add :result, :text, null: false
      add :source, :text, null: false

      timestamps(updated_at: false)
    end
  end
end
