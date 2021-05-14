import Config

# In the config/config.exs file
config :plantproxy, Plantproxy.PartitionedCache,
  primary: [
    gc_interval: :timer.hours(12),
    backend: :shards,
    partitions: 2
  ]
