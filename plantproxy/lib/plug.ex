defmodule Plantproxy.Plug do
  use Plug.Builder

  @moduledoc "Provides access to read stored documents"

  plug(CORSPlug)
  plug(:retrieve)

  import Plug.Conn

  @doc """
  request comes in like https://foo:8081/proxy?src=https://raw.githubusercontent.com/esl/betinfra/main/uml/ci.cd.activity.puml?token=AHUCR5XEIOMMOWHH5ATFMXLAKCQPA
  """
  def retrieve(conn, _opts) do
    # "/prox" <> id = conn.request_path

    # https://hexdocs.pm/plug/Plug.Conn.html#fetch_query_params/2

    conn = Plug.Conn.fetch_query_params(conn)

    IO.puts(inspect(conn.query_params))

    %{"src" => src} = conn.query_params

    {:ok, data} = Plantproxy.get_raw_github(src)
    {:ok, image} = Plantproxy.generate_image(data, src)

    conn
    |> put_resp_header("content-type", "image/png")
    |> resp(200, image)
  end

  # defp respond_with_data(conn, payload, metadata) do
  #   body = Jason.encode!(payload)

  #   conn =
  #     for {key, value} <- metadata, reduce: conn do
  #       conn ->
  #         put_resp_header(conn, to_string(key), to_string(value))
  #     end

  #   conn
  #   |> put_resp_header("content-type", "application/json")
  #   |> resp(200, body)
  # end

  # defp handle_error(conn, {:error, :not_found}) do
  #   resp(conn, 404, "Not Found")
  # end

  # defp handle_error(conn, {:error, _} = err) do
  #   body = inspect(err)
  #   resp(conn, 500, body)
  # end
end
