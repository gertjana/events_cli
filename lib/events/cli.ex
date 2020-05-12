defmodule Events.CLI do
  use ExCLI.DSL, escript: true
  @moduledoc """
  Documentation for Events.CLI module.
  """
  Application.load(:tzdata)

  name "Events"
  description "Store events"

  command :add do
    aliases [:a]

    argument :name, type: :string, help: "[name] The name of the event you want to add"

    argument :tags, type: :string, list: true, help: "zero or more tags to add with the event"

    description "Alias: a args: [name] [tags].. Adds the name and tags for the current date/time"

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

    description "Alias: l args: none Lists the events"

    run _context do
      Events.list() |> Enum.each(fn v -> pr(v) end)
    end
  end

  command :find do
    aliases [:f]

    argument :tag, type: :string, help: "[tag] list events with tag"

    description "Alias: f args [tag] finds all events with the provided tag"
    run context do
      tag = context[:tag]
      Events.find(tag) |> Enum.each(fn v -> pr(v) end)
    end

  end

  command :tags do
    aliases [:t]

    description "Alias: t args: none lists all tags"

    run _context do
      Events.list_tags |> Enum.each(fn x -> IO.puts(x) end)
    end
  end

  defp get_date() do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  defp pr(event) do
    {:ok, date_time, _} = event["date"] |> DateTime.from_iso8601()
    {:ok, date_time_cet} = date_time |> DateTime.shift_zone("Europe/Amsterdam")
    pr_date = date_time |> DateTime.to_date |> Date.to_iso8601()
    [pr_time, _] = date_time_cet |> DateTime.to_time |> Time.to_iso8601() |> String.split(".")
    pr_tags = pr_list(event["tags"])
    pr_name = event["name"] |> String.pad_trailing(20)
    IO.puts("#{pr_date} #{pr_time}   #{pr_name} [#{pr_tags}]")
  end

  defp pr_list(l) do
    case l do
      nil -> ""
      [head|tail]-> tail |> Enum.reduce(head, fn i, acc -> acc <> ", #{i}" end)
    end
  end
end

