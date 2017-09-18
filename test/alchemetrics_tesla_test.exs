defmodule Support.TeslaClient do
  use Tesla
  plug AlchemetricsTesla
  plug Tesla.Middleware.BaseUrl

  adapter(fn env ->
    cond do
      String.match?(env.url, ~r{user/pets}) -> %{env | status: 200, body: "pets"}
      String.match?(env.url, ~r{user/error}) -> raise %Tesla.Error{reason: :generic_error}
    end
  end)
end

defmodule AlchemetricsTeslaTest do
  use ExUnit.Case
  import Mock
  alias AlchemetricsTesla.ExternalServiceMeasurer
  alias Support.TeslaClient

  setup_with_mocks([{Alchemetrics, [], [report: fn _,_,_ -> nil end, count: fn _,_ -> nil end]}]) do
    :ok
  end

  test "report response time" do
    TeslaClient.get("/user/pets?specie=dog")
    assert called Alchemetrics.report("external_call.Support.TeslaClient.get.user.pets.response_time", :_, %{
      metrics: [:p99, :p95, :avg, :min, :max],
      metadata: %{
        type: "external_call.response_time",
        request_details: %{
          service: "Support.TeslaClient",
          route: "get.user.pets",
        }
      }
    })
  end

  test "report response counting" do
    TeslaClient.get("/user/pets?specie=dog")
    assert called Alchemetrics.count("external_call.Support.TeslaClient.get.user.pets.200.count", %{
      metadata: %{
        type: "external_call.count",
        request_details: %{
          service: "Support.TeslaClient",
          route: "get.user.pets",
        },
        response_details: %{
          status_code_group: "2xx",
          status_code: 200,
        }
      }
    })
  end

  test "report exception counting" do
    assert_raise Tesla.Error, fn ->
      TeslaClient.get("/user/error?specie=dog")
    end
    assert called Alchemetrics.count("external_call.Support.TeslaClient.get.user.error.exception.count", %{
      metadata: %{
        type: "external_call.count",
        request_details: %{
          service: "Support.TeslaClient",
          route: "get.user.error",
        }
      }
    })
  end
end
