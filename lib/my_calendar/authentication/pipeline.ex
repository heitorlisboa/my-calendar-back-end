defmodule MyCalendar.Guardian.AuthPipeline do
  # Note that 'typ' is not a typo
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :my_calendar,
    module: MyCalendar.Guardian,
    error_handler: MyCalendar.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: @claims
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
