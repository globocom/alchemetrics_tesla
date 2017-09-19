<h1 align="center">Alchemetrics Tesla</h1>

<p align="center">
  <img alt="Alchemetrics Tesla" src="https://github.com/globocom/alchemetrics_tesla/blob/master/assets/alchemetrics_tesla.png?raw=true" width="128">
</p>

<p align="center">
  Tesla middleware to report external call metrics.
</p>

<p align="center">
  <a href="https://travis-ci.org/globocom/alchemetrics_tesla">
    <img alt="Travis" src="https://travis-ci.org/globocom/alchemetrics_tesla.svg">
  </a>
  <a href="https://hex.pm/packages/alchemetrics_tesla">
    <img alt="Hex" src="https://img.shields.io/hexpm/dt/alchemetrics_tesla.svg">
  </a>
</p>

## About
Alchemetrics Tesla is a very simple middleware that report metrics like `response_time` and calls count.


## Installing
Add to your dependencies:
```elixir
def deps do
  [{:alchemetrics_tesla, "~> 0.1.0"}]
end
```

## Usage
All you need to do is adding the middleware to your Tesla module, like this:

```elixir
defmodule PetsClient do
  use Tesla
  plug Tesla.Middleware.Alchemetrics
  plug Tesla.Middleware.BaseUrl, "http://pets.api.com"

  def dogs do
    get("/v1/dogs/")
  end
end
```

And when you make any request it will be automatically reported:
```elixir
### Sample call
PetsClient.dogs()

### What is reported
# Response time (avg, max, min, p99 and p95)
%{
  metric: (:avg|:max|:min|:p99|p95),
  name: "external_call.PetsClient.get.v1.dogs.response_time",
  value: 592016,
  options:
  [
    application: "MyApp",
    metadata: [
      type: "external_call.response_time",
      request_details: %{
        route: "get.v1.dogs",
        service: "PetsClient"
      }
    ]
  ]
}

# Calls count (last interval and total)
%{
  metric: (:last_interval|:total),
  name: "external_call.PetsClient.get.v1.dogs.200.count",
  value: 1,
  options: [
    application: "MyApp",
    metadata: [
      type: "external_call.count",
      request_details: %{
        route: "get.v1.dogs",
        service: "PetsClient"
      },
      response_details: %{
        status_code: 200,
        status_code_group: "2xx"
      }
    ]
  ]
}
```
