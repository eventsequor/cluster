# Cluster

## Content

 - Parallelism project 
 - Parallelis exercices



 ## Parallelism project 


 This part of the project contains every necesary things to connect an execute code in a cluster

  We are going to push focus on the folder /lib/cluster instance contains a group of code files specialicing to manage de cluster, next to you will see some details of each file

  [application](lib/cluster/application.ex) 

This provides a initial interface to create an application into the nerves, here we handle some supervice process that are necesaries to provide the features and funcionalities in every cluster, and in configured on mix.exs like application to create a instance of this when we start the node. 


  [Load balancer](lib/cluster/load_balancer.ex)
  This group of functions provides the functionality to asigne de node where the code it will run.
  
   [Node Cluster](lib/cluster/node_cluster.ex) 
   
   This provides and interfaces to handle the network when start the node, that is execute when the node starts, and it will try to connect with a node refence to be into the network


   [text](lib/cluster/subprocess.ex) 
   
   Basic function to receive message  
   ç
   It's the most important gruop of function because create a sincronization with local or target foreant to execute projcssto execude code. This functions allows to call to

    [text](lib/cluster/variable.ex)


Execute a function in a node
```` 
  def run_sync_auto_detect(node \\ nil, module, function_name, args) do
    task =
      Task.async(fn ->
        receive do
          {:ok, response} ->
            response

          _ ->
            IO.inspect("Error, something when wrong")
            {:error}
        end
      end)

    node = if node == nil, do: LoadBalancer.get_node(), else: node

    Node.spawn(node, fn ->
      Kernel.send(task.pid, {:ok, Kernel.apply(module, function_name, args)})
    end)

    Task.await(task, :infinity)
  end
code: 
````




## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
