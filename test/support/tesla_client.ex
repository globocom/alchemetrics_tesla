defmodule Support.TeslaClient do
  use Tesla
  plug Tesla.Middleware.Alchemetrics

  adapter(fn env ->
    cond do
      String.match?(env.url, ~r{user/pets}) -> %{env | status: 200, body: "pets"}
      String.match?(env.url, ~r{user/error}) -> raise %Tesla.Error{reason: :generic_error}
    end
  end)
end
