defmodule Cluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cluster.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Cluster.Worker.start_link(arg)
        # {Cluster.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)

    node_name = :"eder@#{Toolshed.hostname()}"
    System.cmd("epmd", ["-daemon"])
    Node.start(node_name)
    VintageNetWiFi.quick_configure("LOCALHOST", "Mefess0727")
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Cluster.Worker.start_link(arg)
      # {Cluster.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Cluster.Worker.start_link(arg)
      # {Cluster.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:cluster, :target)
  end
end
