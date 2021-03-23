defmodule Plantproxy do
  use Nebulex.Caching
  use Logger

  # alias MyApp.Accounts.User
  alias Plantproxy.PartitionedCache, as: Cache
  # alias MyApp.Repo

  @ttl :timer.hours(1)

  @decorate cacheable(cache: Cache, key: {:github, url}, opts: [ttl: @ttl])
  def get_raw_github(url) do
    case HTTPoison.request(:get, url, []) do
      {:ok,
       %HTTPoison.Response{
         body: body,
         status_code: 200
       }} ->
        {:ok, body}

      _ ->
        {:error, "can't fetch url" <> url}
    end
  end

  @decorate cacheable(cache: Cache, key: {:plantuml, path}, opts: [ttl: @ttl])
  def generate_image(data, path) do
    #     ENV PLANTUML_SERVER=host.docker.internal
    # ENV PLANTUML_SERVER_PORT=8080
    plantuml_server = System.fetch_env!("PLANTUML_SERVER")
    plantuml_server_port = System.fetch_env!("PLANTUML_SERVER_PORT")

    image_url = "http://#{plantuml_server}:#{plantuml_server_port}/png/"

    case HTTPoison.request(:post, image_url, data, [{"Content-Type", "text/plain"}]) do
      {:ok,
       %HTTPoison.Response{
         body: body,
         status_code: 200
       }} ->
        {:ok, body}

      resp ->
        Logger.error("bad response : #{inspect(resp)}")
        {:error, "can't generate image"}
    end
  end
end

#   @decorate cacheable(cache: Cache, key: {User, username}, opts: [ttl: @ttl])
#   def get_user_by_username(username) do
#     Repo.get_by(User, [username: username])
#   end

#   @decorate cache_put(
#               cache: Cache,
#               keys: [{User, usr.id}, {User, usr.username}],
#               match: &match_update/1
#             )
#   def update_user(%User{} = usr, attrs) do
#     usr
#     |> User.changeset(attrs)
#     |> Repo.update()
#   end

#   defp match_update({:ok, usr}), do: {true, usr}
#   defp match_update({:error, _}), do: false

#   @decorate cache_evict(cache: Cache, keys: [{User, usr.id}, {User, usr.username}])
#   def delete_user(%User{} = usr) do
#     Repo.delete(usr)
#   end

#   def create_user(attrs \\ %{}) do
#     %User{}
#     |> User.changeset(attrs)
#     |> Repo.insert()
#   end
# end
