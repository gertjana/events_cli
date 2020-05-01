defmodule Events do
  @moduledoc """
  Documentation for Events.
  """
  @store "~/.events.json"
  @ets_store :events

  def start(_type, _args) do
		:ets.new(@ets_store, [:set, :public, :named_table])

    if !File.exists?(Path.expand(@store)), do: File.write(Path.expand(@store), "{}")

		with {:ok, body} <- File.read(Path.expand(@store)),
         {:ok, events} <- Poison.decode(body) do
           years = Map.keys(events)
           Enum.each(years, fn year -> :ets.insert(@ets_store, {String.to_atom(year), Map.get(events, year)}) end)
           :ets.insert(@ets_store, {:years, years})
         end
    {:ok, self()}
  end

  @doc """
    Stores an event
  """
  def store(name, tags) do
    IO.puts("storing #{name} with #{inspect(tags)}")
  end

  @spec list(String.t()) :: any
  def list(year) do
    y = String.to_atom(year)
    :ets.lookup(@ets_store, y)[y]
      |> Enum.map(fn {date, value} -> {date, value} end)
  end

  @spec save(String.t(), %{name: String.t(), tags: list(String.t())}, String.t()) :: any()
  def save(date, value, year) do
    new_map = Enum.into(list(year), %{})
    events = :ets.lookup(@ets_store, :years)[:years]
               |> Enum.map(fn y when y == year -> {y, Map.put(new_map, date, value)}
                              y  -> {y, list(y) |> Enum.into(%{})} end)
               |> Enum.into(%{})
    {:ok, json} = Poison.encode(events, pretty: true)
    File.write(Path.expand(@store), json)
  end

  @spec add(String.t(), String.t(), list(String.t())) :: String.t()
  def add(date, name, tags) do
    value = %{name: name, tags: tags}
    save(date, value, year(date))
    "Added event #{name} with #{inspect(tags)}"
  end

  @spec find(String.t(), String.t()) :: any()
  def find(year, tag) do
    list(year) |> Enum.filter(fn {_, value} -> value["tags"] |> Enum.member?(tag) end)
  end

  @spec list_tags :: MapSet.t(String.t)
  def list_tags() do
    :ets.lookup(@ets_store, :years)[:years]
      |> Enum.flat_map(fn y  -> list(y) |> Enum.into(%{}) end)
      |> Enum.flat_map(fn {_, value} -> value["tags"] end)
      |> MapSet.new()
  end

  @spec year(String.t()) :: String.t()
  def year(date) do
    {:ok, dt, _} = DateTime.from_iso8601(date)
    dt.year |> Integer.to_string
  end

end
