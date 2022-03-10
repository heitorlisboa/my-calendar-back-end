defmodule MyCalendar.Accounts do
  alias MyCalendar.Repo
  alias MyCalendar.Accounts.User

  @spec create_user(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec get_user_by_email(String.t()) :: {:ok, struct()} | {:error, :not_found}
  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
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
