defmodule Cluster.Tasknodecallback do
  def process(node, pid, patter_pid, module, function_name, args) do
    response = Kernel.apply(module, function_name, args)
    Node.spawn(node, fn -> Kernel.send(pid, {patter_pid, response}) end)
  end

  def add(a, b) do
    a + b
  end


end
