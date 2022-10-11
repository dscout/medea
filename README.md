# Medea

Sorceress, wife to Jason, tiny logger of nicely formatted structured messages.

Medea is a tiny package that provides a [formatter][form] and a
[translator][tran] to preserve structured logs. For example, here is the
difference between structured logging with inspection and the structured JSON
we'd expect:

```
# Inspected
"message":"%{args: %{id: 1, on: false}}"

# Structured
"message":{"args":{"id":1, "on":false}}
```

The former contains an inspected Elixir map, while the latter is easily parsable
as JSON.

With Medea, all terms are safely escaped and converted to JSON printable values.
That means structured logging like this:

```elixir
Logger.info(event: %{name: :stuff, safe: false}, user: %User{id: 123})
```

Outputs nested JSON like this:

```
{
  "level":"info",
  "message":{
    "event":{
      "name":"stuff",
      "safe":false
    },
    "user":{
      "id":123
    }
  },
  "metadata":[],
  "time":"2022-10-11T15:07:33.000"
}
```

## Installation

The package can be installed by adding `medea` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:medea, "~> 0.1"}
  ]
end
```

## Usage

Medea has two components: `Medea.Formatter` and `Medea.Translator`. For complete
functionality, both components must be configured.

First, configure the logger backend with the formatter:

```elixir
config :logger, :console,
  format: {Medea.Formatter, :format},
  metadata: [:request_id]
```

Next, enable the translator at the top of your applications `start/2` function:

```elixir
def start(_type, _args) do
  Logger.add_translator({Medea.Translator, :translate})

  children = [
    # whichever children you have
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
end
```

## Logging With Ecto

If you're using Ecto, you should disable the default logger:

```elixir
config :my_app, MyApp.Repo, log: false
```

Now replace it with a simple telemetry based instrumenter that logs structured
queries with metadata:

```elixir
defmodule MyApp.EctoLogger do
  @moduledoc false

  require Logger

  def handle_event(_event, measure, %{query: query, repo: repo}, level) do
    query_meta = Map.take(measure, ~w(idle_time queue_time query_time decode_time total_time)a)

    Logger.log(level, query, repo: inspect(repo), query: query_meta)
  end
end
```

Attach the logger with telemetry:

```elixir
:telemetry.attach(
  "ecto-logger",
  [:my_app, :repo, :query],
  &MyApp.EctoLogger.handle_event/4,
  :info
)
```

Additional documentation can be found at [https://hexdocs.pm/medea](https://hexdocs.pm/medea).

[form]: https://hexdocs.pm/logger/Logger.Formatter.html
[tran]: https://hexdocs.pm/logger/Logger.Translator.html
