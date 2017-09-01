defmodule CgratesWebJsonapi.Cgrates.Adapter do
  use HTTPoison.Base

  def process_url(url) do
    "http://119.28.70.217:2080" <> url
  end

  defp process_request_options(options) do
    options = options ++ [hackney: [basic_auth: {
      Application.get_env(:cgrates_web_jsonapi, :cgrates_username),
      Application.get_env(:cgrates_web_jsonapi, :cgrates_password)
    }]]
  end

  defp process_request_body(%{method: method, params: params}) do
    params = params
    |> ProperCase.to_camel_case(:upper)
    |> Map.merge(%{Tenant: Application.get_env(:cgrates_web_jsonapi, :cgrates_tenant)})

    %{
      method: method,
      params: [params]
    } |> Poison.encode!
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> ProperCase.to_snake_case
  end

  defp process_request_headers(_headers) do
    ["Content-Type": "application/json"]
  end
end
