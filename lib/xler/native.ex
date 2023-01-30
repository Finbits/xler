defmodule Xler.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  force_build = Application.compile_env(:xler, :force_build, false)

  use RustlerPrecompiled,
    otp_app: :xler,
    crate: "xler_native",
    base_url: "https://github.com/Finbits/xler/releases/download/v#{version}",
    force_build: force_build,
    version: version

  def parse(_filename, _worksheet), do: :erlang.nif_error(:nif_not_loaded)
  def worksheets(_filename), do: :erlang.nif_error(:nif_not_loaded)
end
