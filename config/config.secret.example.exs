# Create a file in the same folder with the name `config.secret.exs` following
# the same structure as the example
import Config

config :my_calendar, MyCalendar.Guardian,
  issuer: "my_calendar",
  secret_key: "You can use `mix guardian.gen.secret` to get a secret key"
