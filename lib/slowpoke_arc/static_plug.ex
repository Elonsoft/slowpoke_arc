defmodule SlowpokeArc.StaticPlug do
  @moduledoc """
  Manages serving static files uploaded to slowpoke_arc storage.

  It may be the case that when you returned an URL it was on local storage
  but when front-end party tried to load it, the resource was already
  uploaded on an inet storage and got deleted locally, so with default
  `Plug.Static` we get 404.

  This plug allows to redirect on requests to static files that hadn't
  been found locally.

  It accepts the very same parameters `Plug.Static` does, except it
  requires `:arc_definition` key, have which been not provided, raises
  `MissingArcDefinition` exception. slowpoke arc storage provides
  its own plug that passes `:arc_definition` key into options, so you
  shouldn't use this module directly.
  """

  alias Arc.Actions.Url
  alias Plug.{Conn, HTML, Static}

  @behaviour Plug

  defmodule MissingArcDefinition do
    @moduledoc """
    An exception thrown in case an :arc_definition was not provided.
    """

    defexception [:message]

    def exception(_) do
      %__MODULE__{message: "missing :arc_definition option in plug config"}
    end
  end

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{path_info: path_info} = conn, opts) do
    path = Enum.join(path_info, "/")
    {definition, opts} = pop_definition(opts)

    if path_matches?(path, Keyword.get(opts, :at, "/")) do
      conn
      |> send_static(opts)
      |> redirect_if_not_halted_to(aws_url(path, definition))
    else
      conn
    end
  end

  defp pop_definition(opts) do
    with {nil, _} <- Keyword.pop(opts, :arc_definition) do
      raise MissingArcDefinition
    end
  end

  defp path_matches?(path, at) do
    String.starts_with?("/#{path}", at)
  end

  defp send_static(conn, opts) do
    Static.call(conn, Static.init(opts))
  end

  defp aws_url(path, definition) do
    module = Module.concat(definition, InetStorageDefinition)
    Url.url(module, path, nil, [])
  end

  defp redirect_if_not_halted_to(%Conn{halted: true} = conn, _) do
    conn
  end

  defp redirect_if_not_halted_to(%Conn{} = conn, url) do
    conn
    |> Conn.put_resp_header("location", url)
    |> Conn.put_resp_header("content-type", "text/html")
    |> Conn.send_resp(:moved_permanently, redirect_body(url))
    |> Conn.halt()
  end

  defp redirect_body(url) do
    "<html><body>You are being <a href=\"#{HTML.html_escape(url)}\">redirected</a>.</body></html>"
  end
end
