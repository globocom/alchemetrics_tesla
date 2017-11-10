defmodule Tesla.Middleware.AlchemetricsTest do
  use ExUnit.Case
  import Mock
  alias AlchemetricsTesla.ExternalServiceMeasurer
  alias Support.TeslaClient
  alias Support.TeslaClientWithBaseUrl
  alias Support.TeslaClientWithBaseUrlAfter

  setup_with_mocks([{Alchemetrics, [], [report: fn
    _,function when is_function(function) -> function.()
    _,_ -> nil
  end,
  increment: fn _ -> nil end]}]) do
    :ok
  end

  test "report response time" do
    TeslaClient.get("https://mypets.com/user/pets?specie=dog")
    assert called Alchemetrics.report([
      type: "external_call.response_time",
      request_details: %{
        service: "Support.TeslaClient",
        method: :get,
        protocol: "https",
        domain: "mypets.com",
        port: 443,
      }
    ], :_)
  end

  test "report response time with custom metric route name" do
    TeslaClient.get("https://mypets.com/user/pets?specie=dog", opts: [alchemetrics_metadata: %{route_name: "get-dogs"}])
    assert called Alchemetrics.report([
      extra: %{ route_name: "get-dogs" },
      type: "external_call.response_time",
      request_details: %{
        service: "Support.TeslaClient",
        method: :get,
        protocol: "https",
        domain: "mypets.com",
        port: 443,
      },
    ], :_)
  end

  test "report response counting" do
    TeslaClient.get("http://mypets.com/user/pets?specie=dog")
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        method: :get,
        protocol: "http",
        domain: "mypets.com",
        port: 80,
      },
      response_details: %{
        status_code_group: "2xx",
        status_code: 200,
      }
    ])
  end

  test "report response counting with custom metric route name" do
    TeslaClient.get("http://mypets.com/user/pets?specie=dog", opts: [alchemetrics_metadata: %{route_name: "get-dogs"}])
    assert called Alchemetrics.increment([
      extra: %{ route_name: "get-dogs" },
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        method: :get,
        protocol: "http",
        domain: "mypets.com",
        port: 80,
      },
      response_details: %{
        status_code_group: "2xx",
        status_code: 200,
      },
    ])
  end

  test "report exception counting" do
    assert_raise Tesla.Error, fn ->
      TeslaClient.get("http://mypets.com/user/error?specie=dog")
    end
    assert called Alchemetrics.increment([
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        method: :get,
        protocol: "http",
        domain: "mypets.com",
        port: 80,
      },
      response_details: %{
        status_code_group: :error,
        status_code: :generic_error,
      }
    ])
  end

  test "report exception counting with custom metric route name" do
    assert_raise Tesla.Error, fn ->
      TeslaClient.delete("http://mypets.com/user/error?specie=dog", opts: [alchemetrics_metadata: %{route_name: "delete-pet"}])
    end
    assert called Alchemetrics.increment([
      extra: %{ route_name: "delete-pet" },
      type: "external_call.count",
      request_details: %{
        service: "Support.TeslaClient",
        method: :delete,
        protocol: "http",
        domain: "mypets.com",
        port: 80,
      },
      response_details: %{
        status_code_group: :error,
        status_code: :generic_error,
      }
    ])
  end

  test "report uri details including base url middleware" do
    TeslaClientWithBaseUrl.get("/pets?specie=dog")
    assert called Alchemetrics.report([
      type: "external_call.response_time",
      request_details: %{
        service: "Support.TeslaClientWithBaseUrl",
        method: :get,
        protocol: "http",
        domain: "mypets.com",
        port: 8080,
      }
    ], :_)
  end

  test "alchemetrics middleware always execute before adapter" do
    TeslaClientWithBaseUrlAfter.get("/pets?specie=dog")
    assert called Alchemetrics.report([
      type: "external_call.response_time",
      request_details: %{
        service: "Support.TeslaClientWithBaseUrlAfter",
        method: :get,
        protocol: "http",
        domain: "mypets.com",
        port: 8080,
      }
    ], :_)
  end
end
