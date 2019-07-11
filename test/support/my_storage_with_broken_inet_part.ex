defmodule SlowpokeArcTest.MyStorageWithBrokenInetPart do
  @moduledoc false

  use SlowpokeArc,
    local_storage: SlowpokeArcTest.LocalStorage,
    inet_storage: SlowpokeArcTest.BrokenInetStorage
end
