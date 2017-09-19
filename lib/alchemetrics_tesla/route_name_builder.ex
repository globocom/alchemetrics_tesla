defmodule AlchemetricsTesla.RouteNameBuilder do
  def build(url) do
    Regex.run(~r{^([^:]+://[^/]+)?([^?]+)}, url)
    |> Enum.at(2)
    |> String.split("/")
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(".")
  end
end
