
# Defining a Cache with a partitioned topology
defmodule Plantproxy.PartitionedCache do
  use Nebulex.Cache,
    otp_app: :plantproxy,
    adapter: Nebulex.Adapters.Partitioned,
    primary_storage_adapter: Nebulex.Adapters.Local
end
