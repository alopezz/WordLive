defmodule WordLive.Puzzle do
  alias WordLive.Dictionary

  def new do
    %{word: "DODGE", attempts: []}
  end

  @doc """
  - `{:ok, game}` is returned if the input was accepted, `game` being the updated puzzle state.
  - `{:error, reason}` is returned if the input was not accepted, either because it was invalid
    or because the game was already over.

  :green, :yellow, and :black represent, for each letter, the meaning of
  the letter being in the right position, the letter being in the word but in a different position,
  and the letter not being present, respectively.
  """
  def try_word(%{word: word}, guess) when byte_size(guess) != byte_size(word) do
    {:error, :bad_length}
  end

  def try_word(%{word: word, attempts: attempts} = game, guess) do
    cond do
      won?(game) ->
        {:error, :game_over}

      Dictionary.lookup(guess) ->
        response = compare_words(guess, word)

        game = %{game | attempts: [response | attempts]}

        {:ok, game}

      true ->
        {:error, :noexist}
    end
  end

  def used_letters(%{attempts: attempts}) do
    for attempt <- attempts,
        {color, letter} <- attempt,
        reduce: %{} do
      %{^letter => prev_color} = used ->
        Map.put(
          used,
          letter,
          case color do
            :green -> :green
            :yellow -> if prev_color != :green, do: :yellow, else: prev_color
            color -> color
          end
        )

      used ->
        Map.put(used, letter, color)
    end
  end

  def used_letters(%{}), do: %{}

  def won?(%{attempts: [last_attempt | _rest]}) do
    Enum.all?(last_attempt, &match?({:green, _}, &1))
  end

  def won?(%{attempts: []}) do
    false
  end

  defp compare_words(guess, word) do
    for {guess_letter, word_letter} <- Enum.zip(String.graphemes(guess), String.graphemes(word)) do
      case guess_letter do
        ^word_letter ->
          {:green, guess_letter}

        letter ->
          if String.contains?(word, letter) do
            {:yellow, guess_letter}
          else
            {:black, guess_letter}
          end
      end
    end
  end
end
