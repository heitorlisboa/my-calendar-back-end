defmodule MyCalendar.Accounts do
  alias MyCalendar.Repo
  alias MyCalendar.Accounts.User

  @spec create_user(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec get_user!(binary()) :: struct()
  def get_user!(id), do: Repo.get!(User, id)

  @spec get_user_by_email(String.t()) :: {:ok, struct()} | {:error, :unauthorized}
  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      # Even though the user was not found, I don't wanna return status 404 (not
      # found) because a malicious user could keep trying different emails until
      # they find an email that is registered
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  @spec get_user_id_by_conn(Plug.Conn.t()) :: binary()
  def get_user_id_by_conn(conn) do
    conn
    |> Map.from_struct()
    |> get_in([:private, :guardian_default_claims, "sub"])
  end

  @spec authenticate_user(String.t(), String.t()) :: {:ok, struct()} | {:error, :unauthorized}
  def authenticate_user(email, password) do
    with {:ok, user} <- get_user_by_email(email) do
      case validate_password(password, user.password) do
        false -> {:error, :unauthorized}
        true -> {:ok, user}
      end
    end
  end

  defp validate_password(password, encrypted_password) do
    Bcrypt.verify_pass(password, encrypted_password)
  end
end
