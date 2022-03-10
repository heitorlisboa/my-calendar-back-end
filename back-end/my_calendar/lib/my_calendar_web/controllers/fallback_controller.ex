defmodule MyCalendarWeb.FallbackController do
  use MyCalendarWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{error: "Changeset error", changeset: changeset})
  end

  def call(conn, {:error, status}) when is_atom(status) do
    conn
    |> put_status(status)
    |> json(%{error: "Task with provided ID not found"})
  end
end
