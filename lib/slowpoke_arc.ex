defmodule SlowpokeArc do
  @moduledoc """
  Provides a storage module for Arc.

  With this storage method, all images are stored locally first,
  then are queued to be uploaded to AWS, and after uploading is
  done, the local copy is deleted. Either an uploading is in progress
  or is already done, the returned url for the resource is always
  valid.

  ## Examples

  To use it, define your configured module:

      defmodule MyApp.Storage do
        use SlowpokeArc
      end

  and then you can add it to config:

      config :arc, storage: MyApp.Storage

  By default it uses `Arc.Storage.Local` for locally saved files
  and `Arc.Storage.S3` for uploadings, but you can change this
  behavior by providing options when using. The example above is
  equivalent to the following one:

      defmodule MyApp.Storage do
        use SlowpokeArc,
          local_storage: Arc.Storage.Local,
          inet_storage: Arc.Storage.S3
      end

  ## Configuration

  Configuration of storages is pretty much the same as with default arc
  storages:

      config :arc,
        storage: MyApp.Storage,
        storage_dir: "/pictures_with_cats",
        bucket: "<your-bucket-name>",
        virtual_host: true

      config :ex_aws,
        access_key_id: ["<your-key-id>", :instance_role],
        secret_access_key: ["<your-secret-key>", :instance_role],
        region: "<your-region>"

  ## Static

  You may want to replace your `Plug.Static` with the one that provides
  your storage:

      plug MyApp.Storage.StaticPlug,
        at: "/uploads",
        from: {:my_app, "uploads"}

  See `SlowpokeArc.StaticPlug` for more details.
  """

  defmacro __using__(opts) do
    local_storage = opts[:local_storage] || Arc.Storage.Local
    inet_storage = opts[:inet_storage] || Arc.Storage.S3
    caller_module = __CALLER__.module

    quote do
      def __local_storage__, do: unquote(local_storage)
      def __inet_storage__, do: unquote(inet_storage)

      defmodule LocalStorageDefinition do
        use Arc.Definition
        def __storage, do: unquote(local_storage)
      end

      defmodule InetStorageDefinition do
        use Arc.Definition
        def __storage, do: unquote(inet_storage)
      end

      defmodule StaticPlug do
        @moduledoc """
        StaticPlug for #{__MODULE__} storage.

        See `SlowpokeArc.StaticPlug` for details.
        """

        def init(opts), do: opts

        def call(conn, static_opts) do
          opts = Keyword.put(static_opts, :arc_definition, unquote(caller_module))
          SlowpokeArc.StaticPlug.call(conn, opts)
        end
      end

      def put(definition, version, file_and_scope) do
        SlowpokeArc.Storage.do_put(
          {definition, version, file_and_scope},
          __local_storage__(),
          __inet_storage__()
        )
      end

      def url(definition, version, file_and_scope, opts \\ []) do
        SlowpokeArc.Storage.do_url(
          {definition, version, file_and_scope},
          __local_storage__(),
          __inet_storage__(),
          opts
        )
      end

      def delete(definition, version, file_and_scope) do
        SlowpokeArc.Storage.do_delete(
          {definition, version, file_and_scope},
          __local_storage__(),
          __inet_storage__()
        )
      end
    end
  end
end
