defmodule AlchemetricsTesla do
  import Alchemetrics

  @report_namespace "external_call"

  defmacro __using__(service_name: service_name) do
    quote do
      import Severino.Metrics.Measurers.ExternalService
      @service_name unquote(service_name)
    end
  end

  def report_service_route(method, %URI{host: domain, port: port, scheme: protocol}, service_name, extra_metadata, function) do
    request_details = %{
      service: service_name,
      method: method,
      protocol: protocol,
      domain: domain,
      port: port,
    }
    |> Map.merge(extra_metadata)
    report_response_time(request_details, fn ->
      try do
        function.()
      rescue e in Tesla.Error ->
        e
      end
    end)
    |> count_response(request_details)
    |> respond
  end

  defp report_response_time(request_details, func) do
    [
      type: "#{@report_namespace}.response_time",
      request_details: request_details,
    ]
    |> report(func)
  end

  defp count_response(%Tesla.Error{} = error, request_details) do
    Alchemetrics.increment([
      type: "#{@report_namespace}.count",
      request_details: request_details
    ])
    error
  end

  defp count_response(%Tesla.Env{status: status_code} = response, request_details) do
    first_digit = div(status_code, 100)
    status_code_group = "#{first_digit}xx"
    Alchemetrics.increment([
      type: "#{@report_namespace}.count",
      request_details: request_details,
      response_details: %{
        status_code_group: status_code_group,
        status_code: status_code,
      }
    ])
    response
  end

  defp respond(%Tesla.Error{} = error), do: raise error
  defp respond(%Tesla.Env{} = response), do: response
end
