defmodule WordLive.PuzzleTest do
  use ExUnit.Case
  alias WordLive.Puzzle

  test "used_letters example" do
    game = %{Puzzle.new() | word: "DODGE"}

    result =
      with {:no, _, game} <- Puzzle.try_word(game, "CRANE"),
           {:no, _, game} <- Puzzle.try_word(game, "GROPE") do
        Puzzle.used_letters(game)
      end

    expected = %{
      "C" => :black,
      "R" => :black,
      "A" => :black,
      "N" => :black,
      "E" => :green,
      "G" => :yellow,
      "O" => :yellow,
      "P" => :black
    }

    assert result == expected
  end
end
