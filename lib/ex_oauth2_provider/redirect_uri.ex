defmodule ExOauth2Provider.RedirectURI do
  @moduledoc """
  Functions for dealing with redirect uri.
  """
  alias ExOauth2Provider.{Config, Utils}

  @doc """
  Validates if a url can be used as a redirect_uri
  """
  @spec validate(binary() | nil) :: {:ok, binary()} | {:error, binary()}
  def validate(nil), do: validate("")
  def validate(url) when is_binary(url) do
    url
    |> String.trim()
    |> do_validate()
  end

  defp do_validate(""),
    do: {:error, "Redirect URI cannot be blank"}
  defp do_validate(url) do
    if native_redirect_uri?(url) do
      {:ok, url}
    else
      do_validate(url, URI.parse(url))
    end
  end
  defp do_validate(_url, %{fragment: fragment}) when not is_nil(fragment),
    do: {:error, "Redirect URI cannot contain fragments"}
  defp do_validate(_url, %{scheme: schema, host: host}) when is_nil(schema) or is_nil(host),
    do: {:error, "Redirect URI must be an absolute URI"}
  defp do_validate(url, uri) do
    if invalid_ssl_uri?(uri) do
      {:error, "Redirect URI must be an HTTPS/SSL URI"}
    else
      {:ok, url}
    end
  end

  defp invalid_ssl_uri?(uri) do
    Config.force_ssl_in_redirect_uri?() and uri.scheme == "http"
  end

  @doc """
  Check if uri matches client uri
  """
  @spec matches?(binary(), binary()) :: boolean()
  def matches?(uri, client_uri) when is_binary(uri) and is_binary(client_uri) do
    matches?(URI.parse(uri), URI.parse(client_uri))
  end
  @spec matches?(URI.t(), URI.t()) :: boolean()
  def matches?(%URI{} = uri, %URI{} = client_uri) do
    client_uri == %{uri | query: nil}
  end

  @doc """
  Check if a url matches a client redirect_uri
  """
  @spec valid_for_authorization?(binary(), binary()) :: boolean()
  def valid_for_authorization?(url, client_url) do
    url
    |> validate()
    |> do_valid_for_authorization?(client_url)
  end

  defp do_valid_for_authorization?({:error, _error}, _client_url), do: false
  defp do_valid_for_authorization?({:ok, url}, client_url) do
    client_url
    |> String.split()
    |> Enum.any?(&matches?(url, &1))
  end

  @doc """
  Check if a url is native
  """
  @spec native_redirect_uri?(binary()) :: boolean()
  def native_redirect_uri?(url) do
    Config.native_redirect_uri() == url
  end

  @doc """
  Adds query parameters to uri
  """
  @spec uri_with_query(binary() | URI.t(), map()) :: binary()
  def uri_with_query(uri, query) when is_binary(uri) do
    uri
    |> URI.parse()
    |> uri_with_query(query)
  end
  def uri_with_query(%URI{} = uri, query) do
    query = add_query_params(uri.query || "", query)

    uri
    |> Map.put(:query, query)
    |> to_string()
  end

  defp add_query_params(query, attrs) do
    query
    |> URI.decode_query(attrs)
    |> Utils.remove_empty_values()
    |> URI.encode_query()
  end
end
