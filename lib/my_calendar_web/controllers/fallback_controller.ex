defmodule MyCalendarWeb.FallbackController do
  use MyCalendarWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    error_messages =
      changeset.errors
      |> Enum.map(fn error ->
        {field, {message, _cause}} = error
        to_string(field) <> " " <> message
      end)

    conn
    |> put_status(400)
    |> json(%{error: error_messages})
  end

  def call(conn, {:error, status}) when is_atom(status) do
    status_code =
      try do
        Plug.Conn.Status.code(status)
      rescue
        _invalid_status_code_error -> :unauthorized
      end

    conn
    |> put_status(status_code)
    |> json(%{error: status})
  end
end
