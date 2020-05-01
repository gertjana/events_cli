defmodule Events.CLI do
  use ExCLI.DSL, escript: true
  @moduledoc """
  Documentation for Events.CLI module.
  """

  name "Events"
  description "Store events"

  command :add do
    aliases [:a]

    argument :name, type: :string, help: "[name] The name of the event you want to add"

    argument :tags, type: :string, list: true, help: "zero or more tags to add with the event"

    description "Alias: a\t\targs: [name] [tags]..\t\tAdds the name and tags for the current date/time"

    run context do
      name = context[:name]
      tags = context[:tags]
      new_tags = tags |> Enum.filter(fn tag -> !Enum.member?(Events.list_tags, tag) end)
      if (Enum.empty?(new_tags) || ExPrompt.confirm("#{inspect(new_tags)} are new tags, are you sure you want to add them?")) do
        Events.add(get_date(), name, tags) |> IO.puts
      else
        "Added nothink" |> IO.puts
      end
    end
  end

  command :list do
    aliases [:l]

    argument :year, type: :integer, help: "[year] The year we want to list events for"`

    description "Alias: l\t\targs: [year]\t\tList the events for the specified year"

    run context do
      y = context[:year] |> Integer.to_string
      Events.list(y) |> Enum.each(fn v -> pr(v) end)
    end
  end

  command :find do
    aliases [:f]

    argument :year, type: :integer, help: "[year] The year we want to list events for"

    argument :tag, type: :string, help: "[tag] list events with tag"

    run context do
      year = context[:year] |> Integer.to_string
      tag = context[:tag]
      Events.find(year, tag) |> Enum.each(fn v -> pr(v) end)
    end

  end

  command :tags do
    aliases [:t]

    run _context do
      Events.list_tags |> Enum.each(fn x -> IO.puts(x) end)
    end
  end
  defp get_date() do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  defp pr(event) do
    with {key,value} <- event do
        name = value["name"]
        tags = case value["tags"] do
          nil -> ""
          [head|tail]-> tail |> Enum.reduce(head, fn i, acc -> acc <> ", #{i}" end)
        end
        IO.puts("Date: #{key}\tName: #{name}\tTags: #{tags}")
    end
  end
end

