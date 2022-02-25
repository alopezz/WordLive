defmodule WordLiveWeb.WordLive do
  use WordLiveWeb, :live_view
  use Phoenix.Component

  alias WordLive.Puzzle

  def mount(_params, _session, socket) do
    game =
      if connected?(socket) do
        Puzzle.new()
      else
        %{}
      end

    socket =
      assign(socket,
        current_input: "",
        game: game,
        was_invalid: false,
        error: nil
      )

    {:ok, socket}
  end

  def render(%{current_input: current_input, game: game} = assigns) do
    assigns = assign(assigns, :rows, build_rows(current_input, game))

    ~H"""
    <div id="game" class="grid grid-rows-1 justify-center" phx-window-keydown="key-input">
      <div id="board" class="relative grid grid-rows-6 gap-1 p-3 box-border w-fit">
        <.error_banner error={@error}/>
        <%= for r <- 0..5 do %>
          <.game_row word={Map.get(@rows, r, nil)} was_invalid={@was_invalid}/>
        <% end %>
      </div>
      <WordLiveWeb.Keyboard.keyboard used_letters={Puzzle.used_letters(@game)}/>
    </div>
    """
  end

  # Calculate the map of rows from the game and current UI state
  defp build_rows(current_input, game) do
    [{:current, current_input} | Map.get(game, :attempts, [])]
    |> Enum.reverse()
    |> Enum.with_index(fn element, index -> {index, element} end)
    |> Enum.into(%{})
  end

  def game_row(assigns) do
    letters =
      case assigns[:word] do
        {:current, word} ->
          word
          |> String.pad_trailing(5)
          |> String.graphemes()

        # Empty (future) rows
        nil ->
          [" ", " ", " ", " ", " "]

        # Past attempts
        word ->
          word
      end

    animation_classes =
      case assigns do
        %{was_invalid: true, word: {:current, _word}} ->
          Process.send_after(self(), :clear_invalid, 800)
          "animate-shake"

        _ ->
          ""
      end

    classes = ~w"grid grid-cols-5 gap-1 justify-center #{animation_classes}"

    assigns = assign(assigns, letters: letters, classes: classes)

    ~H"""
    <div class={@classes}>
      <%= for letter <- @letters do %>
        <.tile value={letter}/>
      <% end %>
    </div>
    """
  end

  def tile(assigns) do
    border_classes =
      case assigns[:value] do
        value when value == " " -> "border-2 border-gray"
        value when is_binary(value) -> "border-2 border-black"
        {_state, _value} -> ""
      end

    bg_classes =
      case assigns[:value] do
        {:green, _} -> "bg-green"
        {:yellow, _} -> "bg-yellow"
        {:black, _} -> "bg-neutral"
        _ -> ""
      end

    fg_classes =
      case assigns[:value] do
        {_, _} -> "text-white"
        _ -> "text-black"
      end

    animation_classes =
      case assigns[:value] do
        {_, _} -> "transition-all delay-500 animate-flip"
        " " -> ""
        # Makes a pop animation when a tile goes from empty
        # to having a letter (i.e. when a letter was input)
        value when is_binary(value) -> "animate-pop"
      end

    tile_classes =
      ~w"h-14 w-14 text-4xl flex justify-center items-center #{border_classes} #{bg_classes} #{fg_classes} #{animation_classes}"

    assigns =
      assigns
      |> assign(
        :value,
        case assigns[:value] do
          {_state, letter} -> letter
          letter -> letter
        end
      )
      |> assign(:classes, tile_classes)

    ~H"""
    <div class={@classes}>
      <%= @value %>
    </div>
    """
  end

  def error_banner(assigns) do
    ~H"""
    <div class="absolute flex flex-1 justify-center top-3 left-0 right-0">
      <%= if @error do %>
        <div class="rounded bg-black text-white p-2 z-50"><%= render_error(@error) %></div>
      <% end %>
    </div>
    """
  end

  defp render_error(:bad_length), do: "Word has the wrong length"
  defp render_error(:noexist), do: "Word doesn't exist"
  defp render_error(:game_over), do: "Game's already over"

  def handle_event("key-input", %{"key" => key}, socket) do
    {:noreply, handle_key(socket, key)}
  end

  defp handle_key(socket, key) do
    case key do
      key when byte_size(key) == 1 ->
        key = String.upcase(key)
        if letter?(key), do: input_letter(socket, key), else: socket

      "Backspace" ->
        delete_letter(socket)

      "DEL" ->
        delete_letter(socket)

      "Enter" ->
        submit_word(socket)

      "ENTER" ->
        submit_word(socket)

      _ ->
        socket
    end
  end

  defp input_letter(socket, letter) do
    update(socket, :current_input, fn input ->
      if String.length(input) < 5 do
        input <> letter
      else
        input
      end
    end)
    |> assign(was_invalid: false)
  end

  defp letter?(letter) do
    (String.to_charlist(letter) |> List.first()) in ?A..?Z
  end

  defp delete_letter(socket) do
    update(socket, :current_input, fn input -> String.slice(input, 0..-2) end)
    |> assign(was_invalid: false)
  end

  defp submit_word(%{assigns: %{game: game, current_input: current_input}} = socket) do
    case Puzzle.try_word(game, current_input) do
      {:ok, new_game} ->
        assign(socket, game: new_game, current_input: "", was_invalid: false, error: nil)

      {:error, reason} ->
        assign(socket, was_invalid: true, error: reason)
    end
  end

  def handle_info(:clear_invalid, socket) do
    {:noreply, assign(socket, was_invalid: false, error: nil)}
  end
end
