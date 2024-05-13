# Cluster

## Content

 - Parallelism project 
 - Parallelis exercices



 ## Parallelism project 


 This part of the project contains every necesary things to connect an execute code in a group of cluster

  We are going to push focus on the folder /lib/cluster instance contains a group of code files specialicing to manage de cluster, next to you will see some details of each file

  [application](lib/cluster/application.ex) 

  This provides a initial interface to create an application into the nerves, here we handle some supervice process that are necesaries to provide the features and funcionalities in every cluster, and in configured on mix.exs like application to create a instance of this when we start the node. 


  [Load balancer](lib/cluster/load_balancer.ex)
  This group of functions provides the functionality to asigne the node where the code it will run.
  
  [Node Cluster](lib/cluster/node_cluster.ex) 
   
  This provides and interfaces to handle the network when start the node, that is execute when the node starts, and it will try to connect with a node refence to be into the network


  [Variable](lib/cluster/variable.ex)

  This module allow a cluster to save data in others cluster connected to him, and also connect it locally. Then the user or code can call the function to recover the data and made operations

  [TaskCall](lib/cluster/task_call.ex)
  This module provides a set of interfaces for executing higher-order functions while allowing execution to be distributed across each cluster of nodes connected to the node using these interfaces.





## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi4` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

Clone this repository in your local machine, you can run and test the code that is present in this project

### Local instalation
To start your Nerves app:

* Clean dependencies `mix deps.clean --all`
* Install dependencies with `mix deps.get`
* Then you application is ready to test the modules
  * To connect to other nodes execute `Node.connect(:"name_node@dns_node")`


### Raspberry pi instalation
To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi4`
  * Clean dependencies `mix deps.clean --all`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`
  * Insert your SD card in your raspberry 
  * Then you application is ready to test the modules
  * To connect to other nodes execute `Node.connect(:"name_node@dns_node")`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
