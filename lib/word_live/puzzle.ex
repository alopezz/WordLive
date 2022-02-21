defmodule WordLive.Puzzle do
  def new do
    %{word: "dodge", attempts: []}
  end

  @doc """
  :yes is returned if the word was guessed, :no if the word is valid but the wrong guess,
  and :invalid if the word doesn't exist.

  :green, :yellow, and :black represent, for each letter, the meaning of
  the letter being in the right position, the letter being in the word but in a different position,
  and the letter not being present, respectively.
  """
  def try_word(%{word: word, attempts: attempts} = game, guess) do
    response = compare_words(guess, word)

    game = %{game | attempts: [response | attempts]}

    if guess == word do
      {:yes, response, game}
    else
      {:no, response, game}
    end
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
