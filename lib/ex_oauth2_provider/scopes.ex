defmodule ExOauth2Provider.Scopes do
  @moduledoc """
  Functions for dealing with scopes.
  """

  @doc """
  Check if required scopes exists in the scopes list
  """
  @spec all?([String.t], [String.t]) :: boolean
  def all?(scopes, required_scopes) do
    required_scopes
    |> Enum.find(&!Enum.member?(scopes, &1))
    |> is_nil()
  end

  @doc """
  Check if two lists of scopes are equal
  """
  @spec equal?([String.t], [String.t]) :: boolean
  def equal?(scopes, other_scopes) do
    all?(scopes, other_scopes) && all?(other_scopes, scopes)
  end

  @doc """
  Default scopes for server
  """
  @spec default_server_scopes() :: [String.t]
  def default_server_scopes, do: ExOauth2Provider.Config.default_scopes()

  @doc """
  All scopes for server
  """
  @spec server_scopes() :: [String.t]
  def server_scopes, do: ExOauth2Provider.Config.server_scopes()

  @doc """
  Filter defaults scopes from scopes list
  """
  @spec filter_default_scopes([String.t]) :: [String.t]
  def filter_default_scopes(scopes) do
    Enum.filter(scopes, &Enum.member?(default_server_scopes(), &1))
  end

  @doc """
  Will default to server scopes if no scopes supplied
  """
  @spec filter_default_scopes([String.t]) :: [String.t]
  def default_to_server_scopes([]), do: ExOauth2Provider.Config.server_scopes()
  def default_to_server_scopes(server_scopes), do: server_scopes

  @doc """
  Fetch scopes from an access token
  """
  @spec from_access_token(map) :: [String.t]
  def from_access_token(access_token), do: to_list(access_token.scopes)

  @doc """
  Convert scopes string to list
  """
  @spec to_list(String.t()) :: [String.t]
  def to_list(nil), do: []
  def to_list(str), do: String.split(str)

  @doc """
  Convert scopes list to string
  """
  @spec to_string(list) :: String.t
  def to_string(scopes), do: Enum.join(scopes, " ")
end
