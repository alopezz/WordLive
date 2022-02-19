defmodule WordLiveWeb.WordLive do
  use WordLiveWeb, :live_view
  use Phoenix.Component

  def game_row(assigns) do
    letters = 5
    ~H"""
    <div class="grid grid-cols-5 gap-1 justify-center">
      <%= for _ <- 1..letters do %>
        <.tile value={nil}/>
      <% end %>
    </div>
    """
  end

  def tile(assigns) do
    ~H"""
    <div class="border-2 h-14 w-14 text-4xl">
      <%= @value %>
    </div>
    """
  end
end
