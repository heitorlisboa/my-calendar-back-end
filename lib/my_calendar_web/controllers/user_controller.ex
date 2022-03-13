defmodule MyCalendarWeb.UserController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Accounts
  alias MyCalendar.Accounts.User

  action_fallback MyCalendarWeb.FallbackController

  def register(conn, user_to_create) do
    with {:ok, %User{}} <- Accounts.create_user(user_to_create) do
      conn
      |> put_status(:created)
      |> text("User successfully registered")
    end
  end
end
