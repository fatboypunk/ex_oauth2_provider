defmodule ExOauth2Provider.Token.Utils do
  @moduledoc false

  alias ExOauth2Provider.{OauthApplications, Utils.Error}

  @doc false
  @spec load_client({:ok, map()}) :: {:ok, map()} | {:error, map()}
  def load_client({:ok, %{request: request = %{"client_id" => client_id}} = params}) do
    client_secret = Map.get(request, "client_secret", "")

    case OauthApplications.get_application(client_id, client_secret) do
      nil    -> Error.add_error({:ok, params}, Error.invalid_client())
      client -> {:ok, Map.merge(params, %{client: client})}
    end
  end
  def load_client({:ok, params}), do: Error.add_error({:ok, params}, Error.invalid_request())
  def load_client({:error, params}), do: {:error, params}
end
