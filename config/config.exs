use Mix.Config

config :elixir,
  :time_zone_database, Tz.TimeZoneDatabase

config :tzdata,
  :data_dir, "/etc/elixir_tzdata_data"
