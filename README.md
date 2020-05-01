# Events

Simple cli tool to quickly record events

## Installation

```
mix deps.get
mix escript.build
```
## Usage

```
./events_cli add "Got a coffee" espresso 
./events_cli list
./events_cli find espresso
```

data is stored in `~/.events.json`

