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

defmodule Support.TeslaClientWithBaseUrl do
  use Tesla
  plug Tesla.Middleware.BaseUrl, "http://mypets.com:8080/users"
  plug Tesla.Middleware.Alchemetrics

  adapter(fn env ->
    cond do
      String.match?(env.url, ~r{pets}) -> %{env | status: 200, body: "pets"}
    end
  end)
end

defmodule Support.TeslaClientWithBaseUrlAfter do
  use Tesla
  plug Tesla.Middleware.Alchemetrics
  plug Tesla.Middleware.BaseUrl, "http://mypets.com:8080/users"

  adapter(fn env ->
    cond do
      String.match?(env.url, ~r{pets}) -> %{env | status: 200, body: "pets"}
    end
  end)
end
