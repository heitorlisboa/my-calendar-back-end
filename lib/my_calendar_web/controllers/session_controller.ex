defmodule MyCalendarWeb.SessionController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Accounts
  alias MyCalendar.Accounts.User
  alias MyCalendar.Guardian

  action_fallback MyCalendarWeb.FallbackController

  def new(conn, %{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.authenticate_user(email, password) do
      user_info = %{name: user.name, email: user.email}

      {:ok, access_token, _claims} =
        Guardian.encode_and_sign(user, user_info, token_type: "access")

      {:ok, refresh_token, _claims} =
        Guardian.encode_and_sign(user, user_info, token_type: "refresh")

      conn
      |> put_status(:created)
      |> render("token.json",
        access_token: access_token,
        refresh_token: refresh_token
      )
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, %{"name" => _, "email" => _}} <- Guardian.decode_and_verify(refresh_token),
         {:ok, _old_token_and_claims, {new_access_token, _new_claims}} <-
           Guardian.exchange(refresh_token, "refresh", "access"),
         {:ok, _old_token_and_claims, {new_refresh_token, _new_claims}} <-
           Guardian.refresh(refresh_token) do
      conn
      |> put_status(:created)
      |> render("token.json",
        access_token: new_access_token,
        refresh_token: new_refresh_token
      )
    end
  end
end
