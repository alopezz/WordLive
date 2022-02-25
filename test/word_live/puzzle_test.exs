defmodule WordLive.PuzzleTest do
  use ExUnit.Case
  alias WordLive.Puzzle

  test "win a puzzle" do
    game = %{Puzzle.new() | word: "DODGE"}

    played_game =
      with {:ok, game} <- Puzzle.try_word(game, "CRANE"),
           false <- Puzzle.won?(game),
           {:ok, game} <- Puzzle.try_word(game, "GROPE"),
           false <- Puzzle.won?(game),
           {:ok, game} <- Puzzle.try_word(game, "DODGE") do
        game
      else
        true -> flunk("Declared win too early")
        {:invalid, reason} -> flunk("Invalid input provided (#{to_string(reason)})")
      end

    assert Puzzle.won?(played_game)
  end

  test "used_letters example" do
    game = %{Puzzle.new() | word: "DODGE"}

    result =
      with {:ok, game} <- Puzzle.try_word(game, "CRANE"),
           {:ok, game} <- Puzzle.try_word(game, "GROPE") do
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
