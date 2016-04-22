defmodule Dynamo.Ecto.AdminPool do
  @moduledoc false

  use Dynamo.Pool, name: __MODULE__, adapter: Dynamo.Pool.Poolboy
end
