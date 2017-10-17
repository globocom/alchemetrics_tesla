defmodule Tesla.Middleware.Alchemetrics do
  def call(%Tesla.Env{url: url, method: method, __module__: module, opts: opts} = env, next, [keep_order: true]) do
    extra_metadata = opts[:alchemetrics_metadata]
    service_name = service_name_for(module)
    AlchemetricsTesla.report_service_route(method, URI.parse(url), service_name, extra_metadata, fn ->
      Tesla.run(env, next)
    end)
  end
  def call(env, next, nil) do
    next = next |> add_before_adapter({__MODULE__, :call, [[keep_order: true]]})
    Tesla.run(env, next)
  end

  defp service_name_for(module) do
    [[_, service_name]] = Regex.scan(~r{^Elixir\.(.+)$}, to_string(module))
    service_name
  end

  defp add_before_adapter(next, step) do
    List.insert_at(next, -2, step)
  end
end
