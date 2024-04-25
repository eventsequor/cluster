defmodule Cluster.TaskCall do
  def process(node, pid, patter_pid, module, function_name, args) do
    response = Kernel.apply(module, function_name, args)
    Node.spawn(node, fn -> Kernel.send(pid, {patter_pid, response}) end)
  end

  def add(a, b) do
    a + b
  end

  def receive_message(message) do
    spawn(fn -> IO.inspect(message) end)
  end

  # Node.spawn(n, fn -> Cluster.Tasknodecallback.process(Node.self(), pid, 123, Cluster.Tasknodecallback, :add, [2, 3]) end)
end
