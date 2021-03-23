defmodule Plantproxy.Plug do
  use Plug.Builder

  @moduledoc "Provides access to read stored documents"

  plug(CORSPlug)
  plug(:retrieve)

  def retrieve(conn, _opts) do
    "/" <> id = conn.request_path

    conn |> resp(200, "yeah...")

    # TODO implement the call to the plantuml proxy server

    # case Cache.retrieve(id) do
    #   {:ok, payload, meta} ->
    #     respond_with_data(conn, payload, meta)

    #   :not_cached ->
    #     case BetEpsStore.retrieve(id) do
    #       {:ok, payload, meta} = result ->
    #         :ok = Cache.save(id, result)
    #         respond_with_data(conn, payload, meta)

    #       {:error, _} = err ->
    #         handle_error(conn, err)
    #     end
    # end
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
