defmodule Benchmark.Performance do
  def execute(module, fun, args) do
    start_time = :os.system_time(:millisecond)
    Kernel.apply(module, fun, args)
    :os.system_time(:millisecond) - start_time
  end
end
