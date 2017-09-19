defmodule AlchemetricsTesla.RouteNameBuilderTest do
  alias AlchemetricsTesla.RouteNameBuilder, as: Builder
  use ExUnit.Case

  test "convert paths to namespaces" do
    assert Builder.build("v1/user/pets") == "v1.user.pets"
  end

  test "ignores query string" do
    assert Builder.build("v1/user/pets?species=dog&legs_amount=3") == "v1.user.pets"
  end

  test "ignores ending and beginning '/'" do
    assert Builder.build("/v1/user/pets/") == "v1.user.pets"
  end

  test "protocol and domain" do
    assert Builder.build("https://fauna.api.com/v1/user/pets/") == "v1.user.pets"
  end
end
