import Config

config :medea,
  formatters: %{
    [:metadata, :otel_span_id] => {Medea.FormatterTest.EscapeHatch, :format, []},
    [:metadata, :otel_trace_id] => {Medea.FormatterTest.EscapeHatch, :format, []}
  }
