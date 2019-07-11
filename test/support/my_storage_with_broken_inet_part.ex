defmodule SlowpokeArcTest.MyStorageWithBrokenInetPart do
  use SlowpokeArc,
    local_storage: SlowpokeArcTest.LocalStorage,
    inet_storage: SlowpokeArcTest.BrokenInetStorage
end
