defmodule WordLiveWeb.WordLive do
  use WordLiveWeb, :live_view
  use Phoenix.Component

  def mount(_params, _session, socket) do
    socket = assign(socket,
      current_row: 0,
      current_input: "",
    )
    {:ok, socket}
  end

  def render(%{current_row: current_row, current_input: current_input} = assigns) do
    assigns = assign(assigns, :rows, build_rows({current_row, current_input}, nil))
    ~H"""
    <div id="game" class="grid grid-rows-1 justify-center" phx-window-keydown="key-input">
      <div id="board" class="grid grid-rows-6 gap-1 p-3 box-border w-fit">
        <%= for r <- 0..5 do %>
          <.game_row word={@rows[r]}/>
        <% end %>
      </div>
      <WordLiveWeb.Keyboard.keyboard/>
    </div>
    """
  end

  # Calculate the map of rows from the game and current UI state
  defp build_rows({current_row, current_input}, _game) do
    for row_idx <- 0..5, into: %{} do
      if row_idx == current_row do
        {row_idx, current_input}
      else
        # Take the value from the game
        {row_idx, ""}
      end
    end
  end

  def game_row(assigns) do
    letters =
      assigns[:word]
      |> String.pad_trailing(5)
      |> String.graphemes()
    assigns = assign(assigns, :letters, letters)
    ~H"""
    <div class="grid grid-cols-5 gap-1 justify-center">
      <%= for letter <- @letters do %>
        <.tile value={letter}/>
      <% end %>
    </div>
    """
  end

  def tile(assigns) do
    border_class = if assigns.value == " " do
      "border-gray-300"
    else
      "border-black"
    end
    
    tile_classes = ~w"border-2 h-14 w-14 text-4xl flex justify-center items-center #{border_class}"
    
    assigns = assign(assigns, :classes, tile_classes)
    ~H"""
    <div class={@classes}>
      <%= @value %>
    </div>
    """
  end

  def handle_event("key-input", %{"key" => key}, socket) do
    {:noreply, handle_key(socket, key)}
  end

  defp handle_key(socket, key) do
    case key do
      key when byte_size(key) == 1 ->
        key = String.upcase(key)
        if letter?(key), do: input_letter(socket, key), else: socket
      "Backspace" -> delete_letter(socket)
      "DEL" -> delete_letter(socket)
      _ -> socket
    end
  end

  defp input_letter(socket, letter) do
    update(socket, :current_input,
      fn input ->
        if String.length(input) < 5 do
          input <> letter
        else
          input
        end
      end
    )
  end

  defp letter?(letter) do
    (String.to_charlist(letter) |> List.first()) in ?A..?Z
  end

  defp delete_letter(socket) do
    update(socket, :current_input,
      fn input -> String.slice(input, 0..-2) end)
  end
  
end
