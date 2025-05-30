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

```json
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
    {:medea, "~> 0.2"}
  ]
end
```

## Usage

Medea has two components: `Medea.Formatter` and `Medea.Translator`. For complete
functionality, both components must be configured.

First, configure the default formatter:

```elixir
config :logger, :default_formatter,
  format: {Medea.Formatter, :format},
  metadata: [:request_id]
```

Next, enable the translator at the top of your `c:Application.start/2` function:

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

Now replace it with a simple [telemetry](https://hexdocs.pm/telemetry/readme.html)-based handler that logs structured
queries with metadata:

```elixir
defmodule MyApp.EctoLogger do
  require Logger

  def handle_event(_event, measure, %{query: query, repo: repo}, level) do
    query_meta = Map.take(measure, ~w(idle_time queue_time query_time decode_time total_time)a)

    Logger.log(level, query, repo: inspect(repo), query: query_meta)
  end
end
```

And attach:

```elixir
:telemetry.attach(
  "ecto-logger",
  [:my_app, :repo, :query],
  &MyApp.EctoLogger.handle_event/4,
  :info
)
```

## Custom logger formatting

If you need to format certain values in the log set by other libraries,
for example, `:otel_span_id` and `:otel_trace_id`, then you can configure
medea to send certain keypaths to your own implementation.

This configuration relies on compile-time-only configuration for efficiency,
so it cannot be set in `runtime.exs`.

For example:

Before:

```json
{
  "level":"info",
  "message":{"foo":"bar"},
  "metadata":{
    "otel_span_id":[0,1,2,3,4],
    "otel_trace_id":[3,4,5]
  },
  "time":"2022-10-11T15:07:33.000"
}
```

```elixir
config :medea,
  formatters: %{
    [:metadata, :otel_span_id] => {MyApp.Logs, :format, []},
    [:metadata, :otel_trace_id] => {MyApp.Logs, :format, []}
  }
```

```elixir
defmodule MyApp.Logs do
  def format(_keypath, charlist) when is_list(charlist) do
    to_string(charlist)
  end
end
```

After:

```json
{
  "level":"info",
  "message":{"foo":"bar"},
  "metadata":{
    "otel_span_id":"abc123",
    "otel_trace_id":"def456"
  },
  "time":"2022-10-11T15:07:33.000"
}
```

## Custom `Jason.Encoder` Implementations

Structs that implement [Jason.Encoder](https://hexdocs.pm/jason/Jason.Encoder.html) will use that protocol.
If any implementation is undesirable, as is the case with `Ecto.Association.NotLoaded`
and `Ecto.Schema.Metadata` which both raise errors as of `3.12.3`, it can be disabled at runtime.

```elixir
config :medea, except: [Ecto.Association.NotLoaded, Ecto.Schema.Metadata]
```

Additional documentation can be found at [https://hexdocs.pm/medea](https://hexdocs.pm/medea).

[form]: https://hexdocs.pm/logger/Logger.Formatter.html
[tran]: https://hexdocs.pm/logger/Logger.Translator.html
