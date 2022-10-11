message = Jason.encode_to_iodata!(%{custom: "message", special: true})
time = {{2022, 10, 06}, {16, 38, 00, 120}}
metadata = [request_id: 123, user_id: 123, staff: true]

format = fn -> Medea.Formatter.format(:info, message, time, metadata) end

Benchee.run(%{"format" => format})
