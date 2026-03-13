defmodule ForthWeb.ForthWeb.Evaluations.Evaluation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "evaluations" do
    field :program, :string
    field :result, :string
    field :source, :string

    timestamps(updated_at: false)
  end

  def changeset(evaluation, attrs) do
    evaluation
    |> cast(attrs, [:program, :result, :source])
    |> validate_required([:program, :result, :source])
  end
end
