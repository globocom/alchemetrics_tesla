defmodule Tesla.Middleware.Alchemetrics do
  @behaviour Tesla.Middleware

  def call(%Tesla.Env{url: url, method: method, __module__: module, opts: opts} = env, next, _) do
    extra_metadata = opts[:alchemetrics_metadata]
    service_name = service_name_for(module)
    AlchemetricsTesla.report_service_route(method, URI.parse(url), service_name, extra_metadata, fn ->
      Tesla.run(env, next)
    end)
  end

  defp service_name_for(module) do
    [[_, service_name]] = Regex.scan(~r{^Elixir\.(.+)$}, to_string(module))
    service_name
  end
end
