# Events

Simple cli tool to quickly record events

## Installation

```
mix deps.get
mix escript.build
```
## Usage

```
> ./events_cli
No command provided
usage: Events <command> [<args>]

Commands
   tags/t  args: none             Lists all tags
   find/f  args: [tag]            Finds all events with the provided tag
   list/l  args: [year]           List the events for the specified year
   add/a   args: [name] [tags]..  Adds the name and tags for the current date/time
```

data is stored in `~/.events.json`

