defmodule WordLiveWeb.WordLive do
  use WordLiveWeb, :live_view
  use Phoenix.Component

  def mount(_params, _session, socket) do
    socket = assign(socket,
      current_row: 0,
      rows: %{0 => "", 1 => "", 2 => "", 3 => "", 4 => "", 5 => ""}
    )
    {:ok, socket}
  end

  def render(assigns) do
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

  def game_row(assigns) do
    letters =
      assigns[:word]
      |> String.pad_trailing(5)
      |> String.split( "", trim: true)
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
    ~H"""
    <div class="border-2 h-14 w-14 text-4xl flex justify-center items-center">
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
    update(socket, :rows,
      fn rows ->
        current_row = socket.assigns[:current_row]
        if String.length(rows[current_row]) < 5 do
          Map.put(rows, current_row, rows[current_row] <> letter)
        else
          rows
        end
      end
    )
  end

  defp letter?(letter) do
    (String.to_charlist(letter) |> List.first()) in ?A..?Z
  end

  defp delete_letter(socket) do
    update(socket, :rows,
      fn rows ->
        current_row = socket.assigns[:current_row]
        Map.put(rows, current_row, String.slice(rows[current_row], 0..-2))
      end
    )
  end
  
end
