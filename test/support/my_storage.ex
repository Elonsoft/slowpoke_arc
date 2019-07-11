defmodule SlowpokeArcTest.MyStorage do
  @moduledoc false

  use SlowpokeArc,
    local_storage: SlowpokeArcTest.LocalStorage,
    inet_storage: SlowpokeArcTest.InetStorage
end
