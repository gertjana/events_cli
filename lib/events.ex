defmodule Events do
  @moduledoc """
  Documentation for Events.
  """
  @store "~/.events.json"
  @ets_store :events

  @type event :: %{
    date: String.t,
    name: String.t,
    tags: list(String.t)
  }

  def start(_type, _args) do
		:ets.new(@ets_store, [:set, :public, :named_table])

    if !File.exists?(Path.expand(@store)), do: File.write(Path.expand(@store), "{}")

		with {:ok, body} <- File.read(Path.expand(@store)),
         {:ok, events} <- Poison.decode(body) do
          :ets.insert(@ets_store, {:events, events})
    end
    {:ok, self()}
  end

  @spec list() :: [event]
  def list(), do: :ets.lookup(@ets_store, :events)[:events]

  @spec save(event()) :: any()
  def save(event) do
    events = [event | :ets.lookup(@ets_store, :events)[:events]]
    {:ok, json} = Poison.encode(events, pretty: true)
    File.write(Path.expand(@store), json)
  end

  @spec add(String.t(), String.t(), list(String.t())) :: String.t()
  def add(date, name, tags) do
    value = %{date: date, name: name, tags: tags}
    save(value)
    "Added event #{name} with #{inspect(tags)}"
  end

  @spec find(String.t()) :: [event()]
  def find(tag) do
    list() |> Enum.filter(fn event -> event["tags"] |> Enum.member?(tag) end)
  end

  @spec list_tags :: MapSet.t(String.t)
  def list_tags() do
    :ets.lookup(@ets_store, :events)[:events]
      |> Enum.flat_map(fn event -> event["tags"] end)
      |> MapSet.new()
  end

  @spec year(String.t()) :: String.t()
  def year(date) do
    {:ok, dt, _} = DateTime.from_iso8601(date)
    dt.year |> Integer.to_string
  end

end
