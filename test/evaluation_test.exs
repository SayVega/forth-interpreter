defmodule Forth.EvaluationTest do
  use Forth.DataCase

  alias Forth.Repo
  alias Forth.Evaluation

  import Ecto.Query

  describe "changeset validation" do
    test "valid evaluation changeset" do
      attrs = %{
        program: "1 2 +",
        result: "[3]",
        source: "manual"
      }

      changeset = Evaluation.changeset(%Evaluation{}, attrs)

      assert changeset.valid?
    end

    test "changeset allows nil program" do
      attrs = %{
        program: nil,
        result: "[3]",
        source: "manual"
      }

      changeset = Evaluation.changeset(%Evaluation{}, attrs)

      assert changeset.valid?
    end

    test "invalid without result" do
      attrs = %{
        program: "1 2 +",
        source: "manual"
      }

      changeset = Evaluation.changeset(%Evaluation{}, attrs)

      refute changeset.valid?
    end

    test "invalid without source" do
      attrs = %{
        program: "1 2 +",
        result: "[3]"
      }

      changeset = Evaluation.changeset(%Evaluation{}, attrs)

      refute changeset.valid?
    end
  end

  describe "database persistence" do
    test "evaluation is persisted" do
      attrs = %{
        program: "1 2 +",
        result: "[3]",
        source: "manual"
      }

      {:ok, eval} =
        %Evaluation{}
        |> Evaluation.changeset(attrs)
        |> Repo.insert()

      assert eval.program == "1 2 +"
      assert eval.result == "[3]"
      assert eval.source == "manual"
    end

    test "database rejects null program" do
      assert_raise Postgrex.Error, fn ->
        Repo.insert!(%Evaluation{
          program: nil,
          result: "[3]",
          source: "manual"
        })
      end
    end
  end

  describe "history query" do
    test "returns newest evaluations first" do
      Repo.insert!(%Evaluation{
        program: "1",
        result: "[1]",
        source: "manual"
      })

      Repo.insert!(%Evaluation{
        program: "2",
        result: "[2]",
        source: "manual"
      })

      history =
        Repo.all(
          from e in Evaluation,
            order_by: [desc: e.id]
        )

      assert length(history) == 2
      assert hd(history).program == "2"
    end
  end
end
