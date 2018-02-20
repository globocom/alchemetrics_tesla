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
  [{:alchemetrics_tesla, "~> 1.0"}]
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
[
  type: "external_call.response_time",
  request_details: %{
    service: "PetsClient",
    domain: "pets.api.com",
    method: :get,
    port: 80,
    protocol: "http",
  }
]

# Calls count (last interval and total)
[
  type: "external_call.count",
  request_details: %{
    service: "PetsClient",
    domain: "pets.api.com",
    method: :get,
    port: 80,
    protocol: "http",
  },
  response_details: %{
    status_code: "200",
    status_code_group: "2xx"
  }
]
```

### Adding extra metric metadata
You can also add extra metadata:

```elixir
defmodule PetsClient do
  use Tesla
  plug Tesla.Middleware.Alchemetrics
  plug Tesla.Middleware.BaseUrl, "http://pets.api.com"

  def dogs do
    get("/v1/dogs/", opts: [alchemetrics_metadata: %{route: "get.dogs"}])
  end

  def logged_user_pet(pet_id) do
    get("/user/pets/#{pet_id}", opts: [alchemetrics_metadata: %{route: "get.user.pets.show"}])
  end
end
```

This extra metadata will be added to `request_details` key:
```elixir
## Sample call (1)
PetsClient.logged_user_pet(100)

# Reported response time (avg, max, min, p99 and p95)
[
  type: "external_call.response_time",
  request_details: %{
    service: "PetsClient",
    domain: "pets.api.com",
    method: :get,
    port: 80,
    protocol: "http",
  },
  extra: %{ route: "get.user.pets" }
]


## Sample call (2)
PetsClient.dogs()

# Reported response time (avg, max, min, p99 and p95)
[
  type: "external_call.response_time",
  request_details: %{
    service: "PetsClient",
    domain: "pets.api.com",
    method: :get,
    port: 80,
    protocol: "http",
  },
  extra: %{ route: "get.dogs" }
]
```
