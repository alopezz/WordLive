defmodule WordLiveWeb.Keyboard do
  @moduledoc """
  Phoenix Components to build an on-screen keyboard
  """

  use Phoenix.Component

  # All rows of keys
  @keys [
    ~w[Q W E R T Y U I O P],
    ~w[A S D F G H J K L],
    ~w[Z X C V B N M],
    ~w[ENTER DEL]
  ]

  def keyboard(assigns) do
    assigns = assign(assigns, keys: assigns[:keys] || @keys)
    ~H"""
    <div class="flex-rows-3 w-full justify-self-center">
      <%= for key_row <- @keys do %>
        <.row keys={key_row}/>
      <% end %>
    </div>
    """
  end

  def row(assigns) do
    ~H"""
    <div class="flex justify-center mt-0 mb-1">
      <%= for key <- @keys do %>
        <.key key={key}/>
      <% end %>
    </div>
    """
  end

  def key(assigns) do
    assigns = assign(assigns, :event, "keyboard-#{assigns[:key]}")
    ~H"""
    <button class="flex flex-1 justify-center items-center mr-2 h-10 bg-gray-300 rounded" phx-click={@event}>
      <%= @key %>
    </button>
    """
  end
  
end
