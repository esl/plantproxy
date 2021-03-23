defmodule Plantproxy.Application do
  use Application

  @moduledoc false

  @impl true
  def start(_type, _args) do
    port = 8081

    children = [
      {Plug.Cowboy, scheme: :http, plug: Plantproxy.Plug, port: port},
      Plantproxy.PartitionedCache
    ]

    opts = [strategy: :one_for_one, name: BetEpsWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
