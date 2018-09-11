defmodule AlchemetricsTesla do
  import Alchemetrics

  @report_namespace "external_call"

  defmacro __using__(service_name: service_name) do
    quote do
      @service_name unquote(service_name)
    end
  end

  def report_service_route(method, %URI{host: domain, port: port, scheme: protocol}, service_name, extra_metadata, function) do
    request_details = %{
      service: service_name,
      method: method,
      protocol: normalize_to_atom(protocol),
      domain: normalize_to_atom(domain),
      port: normalize_to_atom(port),
    }
    report_response_time(request_details, extra_metadata, fn ->
      function.()
      |> count_response(request_details, extra_metadata)
    end)
  end

  defp report_response_time(request_details, extra_metadata, func) do
    [
      type: "#{@report_namespace}.response_time",
      request_details: request_details,
    ]
    |> put_unless_nil(:extra, extra_metadata)
    |> report(func)
  end

  defp count_response({:ok, %Tesla.Env{status: status_code} = env}, request_details, extra_metadata) do
    first_digit = div(status_code, 100)
    status_code_group = :"#{first_digit}xx"
    [
      type: "#{@report_namespace}.count",
      request_details: request_details,
      response_details: %{
        status_code_group: status_code_group,
        status_code: normalize_to_atom(status_code),
      }
    ]
    |> put_unless_nil(:extra, extra_metadata)
    |> Alchemetrics.increment
    {:ok, env}
  end

  defp count_response({:error, reason}, request_details, extra_metadata) do
    [
      type: "#{@report_namespace}.count",
      request_details: request_details,
      response_details: %{
        status_code_group: :error,
        status_code: normalize_to_atom(reason),
      }
    ]
    |> put_unless_nil(:extra, extra_metadata)
    |> Alchemetrics.increment
    {:error, reason}
  end

  defp normalize_to_atom(nil), do: :unknown
  defp normalize_to_atom(value) when is_atom(value), do: value
  defp normalize_to_atom(value) when is_binary(value), do: String.to_atom(value)
  defp normalize_to_atom(value) do
    value
    |> to_string
    |> String.to_atom()
  end

  defp put_unless_nil(keyword_list, _key, nil), do: keyword_list
  defp put_unless_nil(keyword_list, key, value) do
    Keyword.put(keyword_list, key, value)
  end
end
