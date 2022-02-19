defmodule WordLive.Repo do
  use Ecto.Repo,
    otp_app: :word_live,
    adapter: Ecto.Adapters.Postgres
end
