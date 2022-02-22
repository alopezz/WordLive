defmodule WordLive.Dictionary do
  use GenServer

  def lookup(word) do
    word = String.downcase(word)

    case :ets.lookup(__MODULE__, word) do
      [] -> false
      [{^word, true}] -> true
    end
  end

  def start_link(opts) do
    dict_file = process_opts(opts)
    GenServer.start_link(__MODULE__, dict_file, name: __MODULE__)
  end

  defp process_opts(opts) do
    case opts do
      [] -> Application.app_dir(:word_live, ["priv", "words.txt"])
      [dict_file] -> dict_file
      dict_file -> dict_file
    end
  end

  def init(dict_file) do
    :ets.new(__MODULE__, [:named_table])

    # TODO Handle error here
    File.open(dict_file, fn file ->
      IO.stream(file, :line)
      |> Enum.each(fn word ->
        :ets.insert(__MODULE__, {String.trim(word), true})
      end)
    end)

    {:ok, nil}
  end
end
