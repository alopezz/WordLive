defmodule WordLive.Puzzle do
  alias WordLive.Dictionary

  def new do
    %{word: "DODGE", attempts: []}
  end

  @doc """
  :yes is returned if the word was guessed, :no if the word is valid but the wrong guess,
  and :invalid if the word doesn't exist.

  :green, :yellow, and :black represent, for each letter, the meaning of
  the letter being in the right position, the letter being in the word but in a different position,
  and the letter not being present, respectively.
  """
  def try_word(%{word: word} = game, guess) when byte_size(guess) != byte_size(word) do
    {:invalid, :wrong_length, game}
  end

  def try_word(%{word: word, attempts: attempts} = game, guess) do
    if Dictionary.lookup(guess) do
      response = compare_words(guess, word)

      game = %{game | attempts: [response | attempts]}

      if guess == word do
        {:yes, response, game}
      else
        {:no, response, game}
      end
    else
      {:invalid, :noexist, game}
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
