defmodule AlchemetricsTesla.ExternalServiceMeasurer do
  import Alchemetrics

  @report_namespace "external_call"

  defmacro __using__(service_name: service_name) do
    quote do
      import Severino.Metrics.Measurers.ExternalService
      @service_name unquote(service_name)
    end
  end

  def report_service_route(service_name, route_name, function) do
    measure_response_time(service_name, route_name, fn ->
      try do
        function.()
      rescue e in Tesla.Error ->
        e
      end
    end)
    |> count_response(service_name, route_name)
    |> respond
  end

  defp measure_response_time(service_name, route_name, func) do
    report_time("#{@report_namespace}.#{service_name}.#{route_name}.response_time", %{
        metrics: [:p99, :p95, :avg, :min, :max],
        metadata: %{
          type: "#{@report_namespace}.response_time",
          request_details: %{
            service: service_name,
            route: route_name,
          }
        }
    }) do
      func.()
    end
  end

  defp count_response(%Tesla.Error{} = error, service_name, route_name) do
    Alchemetrics.count("#{@report_namespace}.#{service_name}.#{route_name}.exception.count", %{
      metadata: %{
        type: "#{@report_namespace}.count",
        request_details:  %{
          service: service_name,
          route: route_name,
        }
      }
    })
    error
  end

  defp count_response(%Tesla.Env{status: status_code} = response, service_name, route_name) do
    first_digit = div(status_code, 100)
    status_code_group = "#{first_digit}xx"
    Alchemetrics.count("#{@report_namespace}.#{service_name}.#{route_name}.#{status_code}.count", %{
      metadata: %{
        type: "#{@report_namespace}.count",
        request_details:  %{
          service: service_name,
          route: route_name,
        },
        response_details: %{
          status_code_group: status_code_group,
          status_code: status_code,
        }
      }
    })
    response
  end

  defp respond(%Tesla.Error{} = error), do: raise error
  defp respond(%Tesla.Env{} = response), do: response

  defmacro report_route(route_name, do: function) do
    quote do
      report_service_route(@service_name, unquote(route_name), fn -> unquote(function) end)
    end
  end
end
