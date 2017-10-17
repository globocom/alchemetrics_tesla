defmodule Tesla.Middleware.AlchemetricsTest do
  use ExUnit.Case
  import Mock
  alias AlchemetricsTesla.ExternalServiceMeasurer
  alias Support.TeslaClient
  alias Support.TeslaClientWithCustomRoutes

  setup_with_mocks([{Alchemetrics, [], [report: fn
    _,function when is_function(function) -> function.()
    _,_ -> nil
  end,
  increment: fn _ -> nil end]}]) do
    :ok
  end

  test "report response time" do
    TeslaClient.get("/user/pets?specie=dog")
    assert called Alchemetrics.report([
      type: "external_call.response_time",
      request_details: %{
        service: "Support.TeslaClient",
        route: "get.user.pets",
      }
    ], :_)
  end

  test "report response counting" do
    TeslaClient.get("/user/pets?specie=dog")
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        route: "get.user.pets",
      },
      response_details: %{
        status_code_group: "2xx",
        status_code: 200,
      }
    ])
  end

  test "report exception counting" do
    assert_raise Tesla.Error, fn ->
      TeslaClient.get("/user/error?specie=dog")
    end
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        route: "get.user.error",
      }
    ])
  end

  test "can specify custom route names for specific patterns" do
    TeslaClientWithCustomRoutes.delete("/user/pets/10")
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClientWithCustomRoutes",
        route: "delete.user.pet",
      },
      response_details: %{
        status_code_group: "2xx",
        status_code: 200,
      }
    ])
  end

  test "custom route names patterns have precedence if declared first" do
    TeslaClientWithCustomRoutes.get("/user/pets/10/specie?specie=dog")
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClientWithCustomRoutes",
        route: "get.user.pets.specie",
      },
      response_details: %{
        status_code_group: "2xx",
        status_code: 200,
      }
    ])
  end
end
