defmodule MyCalendarWeb.SessionController do
  use MyCalendarWeb, :controller

  alias MyCalendar.Accounts
  alias MyCalendar.Guardian

  action_fallback MyCalendarWeb.FallbackController

  def new(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password) do
      {:ok, access_token, _claims} =
        Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minute})

      {:ok, refresh_token, _claims} =
        Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day})

      conn
      # ruid = refresh unique id
      |> put_resp_cookie("ruid", refresh_token)
      |> put_status(:created)
      |> render("token.json", access_token: access_token)
    end
  end

  def refresh(conn, _params) do
    refresh_token =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Map.from_struct()
      |> get_in([:cookies, "ruid"])

    with {:ok, _old_token_and_claims, {new_access_token, _new_claims}} <-
           Guardian.exchange(refresh_token, "refresh", "access") do
      conn
      |> put_status(:created)
      |> render("token.json", access_token: new_access_token)
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_resp_cookie("ruid")
    |> put_status(:ok)
    |> text("Sucessfully logged out")
  end
end
