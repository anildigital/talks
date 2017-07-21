#  Distributed Systems in Elixir

#### Distribution primitives in Elixir/Erlang
* Message passing
  - We create processes in Erlang and communication message passing

* Nodes
  - We start different BEAM instances and those are called nodes. Nodes can communicate with each other
  - A node is a system running the Erlang VM with a given name.
  - e.g :justin@bieber.com (much like email address)
  - short names (within same IP domain), long names (resolvable dns / ip)


* Starting Erlang cluster
  - Blitzy example (demo)

  ![Blitzy](https://anil-screenshots.s3.amazonaws.com/Chapter_8._Distribution_and_load_balancing_-_The_Little_Elixir__OTP_Guidebook_2017-07-21_22-34-15.png)

  - Call blitzy worker
  ```
  iex> Blitzy.Worker.start("http://www.bieberfever.com")
  iex> Blitzy.run(10, "http://www.bieberfever.com")
  iex> Blitzy.run(1000, "http://www.bieberfever.com") |> Blitzy.parse_results
  ```
  - Location transparency
  - Processes in an Elixir/Erlang cluster are location transparent. PID can be in same Erlang VM or in another Node. Elixir/Erlangs treats both same
  - This means it’s just as easy to send a message between processes on a single node as it is to do so on a different node, as long as you know the process id of the recipient process.

  ![](https://anil-screenshots.s3.amazonaws.com/08fig02_alt.jpg)

  - Creating cluster
  - We can connect Nodes to each other. They can form a cluster.
  - Node disconnects can happen because of network disruption

  ```
  iex --sname barry
  iex --sname robin
  iex --sname maurice
  ```
  - Nodes must have unique names.

  - Connecting nodes
  ```
  Node.connect(:barry@localhost)
  Node.list
  ```
  - Node connections are transitive
  - ![](http://take.ms/Z2Mcs)

  -  cluster = [node | Node.list]

  - Remotely executing a function

  - rpc multicall

  ```
  :rpc.multicall(cluster, Blitzy.Worker, :start, ["http://www.bieberfever.com"])
  ```
  -	without even assigning cluster
  ```
  :rpc.multicall(Blitzy.Worker, :start, ["http://www.bieberfever.com"])
  ```

  ```
  :rpc.multicall(Blitzy, :run, [5, "http://www.bieberfever.com"], :infinity)
  ```

  - Making Blitzy Distributed
  - Open config.exs to set master node and slave nodes

  - Lets make it a command line app
  ```
  ./blitzy -n [requests] [url]
  ```
  - Connecting nodes
  ```
  Application.get_env(:blitzy, :master_node)
  Application.get_env(:blitzy, :slave_nodes)
  ```
  - Supervising Tasks with Tasks.Supervisor
  - You don’t want a crashing Task to bring down the entire application. This is especially the case when you’re spawning thousands of Tasks (or more!).

   ![](http://take.ms/O3cj0)

 - Create command line build
   ```
   mix escript.build
   ```

 - Running Blitzy
   ```
   iex --name b@127.0.0.1 -S mix
   iex --name c@127.0.0.1 -S mix
   iex --name d@127.0.0.1 -S mix

   ./blitzy -n 10000 http://www.bieberfever.com
   ```

  - Summary
    - The built-in functions Elixir and the Erlang VM provide for building distributed systems
    - Implementing a distributed application that demonstrates load-balancing

-----------------------------------------------------------------


* Distribution and fault tolerance
  - Lets see how a cluster handles failures by having another node automatically stepping up to take the place of a downed node.
  - How a downed node yields control when a previously downed node of high priority joins cluster
  - Demonstrates failover and takeover capabilities of distributed Elixir
    - Failover (defintiion)
    - Takeover (defintiion)

  - Lets implement Distributed & Fault tolerant Chucky facts server

  ```
  iex(1)> Chucky.fact
  "Chuck Norris's keyboard doesn't have a Ctrl key because nothing controls Chuck Norris."

  iex(2)> Chucky.fact
  "All arrays Chuck Norris declares are of infinite size, because Chuck Norris knows no bounds."
  ```

  - Process registration
  ```
  iex(node1@localhost)> Process.register(self, :shell)
  true

  iex(node2@localhost)> Process.register(self, :shell)
  true

  iex(node1@localhost)> send(
    {:shell, :node2@localhost}, "Hello from node1"
    )

  iex(node2@localhost)> lush
  "Hello from node1!"    
  ```

  - Process discovery
     1. A client process must obtain the server’s pid.
     2. A client sends a message to the server.
    - In step 1, you discover a process. Even in a single-node system, you must somehow find the target process pid.
    - The simplest way to do cluster-wide discovery is to use the :global module

  ```
      iex(node1@localhost)> :global.register_name({:todo_list, "bob"}, self)
      :yes
      iex(node2@localhost)> :global.register_name({:todo_list, "bob"}, self)
      :no

      iex(node2@localhost)> :global.whereis_name({:todo_list, "bob"})
    #PID<7954.59.0>
  ```
     - How it is implemented? No special magic.
     - It’s just an elaborate, multinode-aware version of a process registry.
     - When you attempt to register a global alias, a cluster-wide lock is set, preventing any competing registration on other nodes. Then the check is performed to see whether the alias is already registered. If not, all nodes are informed about the new registration. Finally, the lock is released. Obviously, this involves a lot of chatter, and multiple small messages are passed between nodes.

     - Note that lookups are local. When a registration is being performed, all nodes are contacted, and they cache the registration information in their local ETS tables. Each subsequent lookup on any node is performed on that node, without any additional chatter. This means a lookup can be performed quickly, whereas registration requires chatting between nodes.

     - :pg2 (http://erlang.org/doc/man/pg2.html) module allows you to create arbitrarily named cluster-wide groups and add multiple processes to those groups.
     - :pg2 - in redundant clusters, you want to keep multiple copies of the same data. Having multiple copies allows you to survive node crashes. If one node terminates, a copy should exist somewhere else in the cluster.
     ```
     iex(node1@localhost)11> :pg2.start
     iex(node1@localhost)12> :pg2.create({:todo_list, "bob"})
     :ok

      This group is immediately visible on node2

     iex(node2@localhost)9> :pg2.start
     iex(node2@localhost)10> :pg2.which_groups
     [todo_list: "bob"]

     iex(node2@localhost)11> :pg2.join({:todo_list, "bob"}, self)
     :ok

     iex(node1@localhost)13> :pg2.get_members({:todo_list, "bob"})
     [#PID<8531.59.0>]

     iex(node1@localhost)14> :pg2.join({:todo_list, "bob"}, self)
     :ok

     iex(node1@localhost)15> :pg2.get_members({:todo_list, "bob"})
     [#PID<8531.59.0>, #PID<0.59.0>]

     iex(node2@localhost)12> :pg2.get_members({:todo_list, "bob"})
     [#PID<0.59.0>, #PID<7954.59.0>]          
     ```
     - Group creations and joins are propagated across the cluster, but lookups are performed on a locally cached ETS table. Process crashes and node disconnects are automatically detected, and nonexistent processes are removed from the group.

  - Links & Monitors
    - Links and monitors work even if processes reside on different nodes.
    ```
    $ iex --sname node1@localhost
    $ iex --sname node2@localhost
    $ iex(node2@localhost)2> Node.connect(:node1@localhost)
    $ iex(node2@localhost)3> :global.register_name({:todo_list, "bob"}, self())
    $ iex(node1@localhost)1> Process.monitor(
      ...(node1@localhost)1> :global.whereis_name({:todo_list, "bob"})
      ...(node1@localhost)1> )
    # Ctrl + C node2
    $ iex(node1@localhost)2> flush  
    ```
    - Locks
    ```
    iex(node1@localhost)1> :global.set_lock({:some_resource, self})
    true

    iex(node1@localhost)1> :global.set_lock({:some_resource, self}) # blocks until lock is released on node1

    iex(node1@localhost)1> :global.del_lock({:some_resource, self})
    true    
    ```
    - http://erlang.org/doc/man/global.html#trans-2 helper
    - which takes the lock, then runs the provided lambda, and finally releases the lock.

  - Cluster
    - Cluster of 3 nodes
    ```
    a@<host>, b@<host>, and c@<host>
    ```
  - Node a is the master node, and b and c are the slave nodes.
  - The cluster is fully initialized when all the nodes have started.
  - In other words, only after a, b, and c are initialized is the cluster usable.
  - All requests are handled by a@host, no matter which node receives the request.
  ![](https://www.safaribooksonline.com/library/view/the-little-elixir/9781633430112/09fig02_alt.jpg)

  - When a fails, the remaining nodes will, after a timeout period, detect the failure. Node b will then spin up the application
  ![](https://www.safaribooksonline.com/library/view/the-little-elixir/9781633430112/09fig03_alt.jpg)

  - When b fails, c spins up application

  - Let’s consider what happens when a restarts.

  - Once a@host is back, it initiates a takeover.
  ![](https://www.safaribooksonline.com/library/view/the-little-elixir/9781633430112/09fig04_alt.jpg)

  - Whichever slave node is running, the application exits and yields control to the master node.

  - Lets do this!

  - create configuration files for each of the nodes
    - a.config
    - b.config
    - c.config

  -	`sync_nodes_mandatory` — List of nodes that must be started within the time specified by `sync_nodes_timeout`.
  - `sync_nodes_optional` - List of nodes that can be started within the time specified by `sync_nodes_timeout`. (Note that you don’t use this option for this application.)
  - `sync_nodes_timeout` — How long to wait for the other nodes to start (in milliseconds).

  - Start the distributed application
  ```
  iex --sname a -pa _build/dev/lib/chucky/ebin --app chucky --erl "-config config/a.config"
  iex --sname b -pa _build/dev/lib/chucky/ebin --app chucky --erl "-config config/b.config"
  iex --sname c -pa _build/dev/lib/chucky/ebin --app chucky --erl "-config config/c.config"
  ```

  - Failover and takeover in action
  - Failover 
  ```
  iex(a@Alchemist)1> Chucky.fact
  "Chuck Norris brushes his teeth with a mixture of iron shavings, industrial paint remover, and boner-grain alcohol."
  iex(a@Alchemist)1> Application.started_applications
  ```

  - Takeover

  ```
  iex --sname a -pa _build/dev/lib/chucky/ebi--app chucky --erl "-config config/a.config"
  ```

  - Implementing replicated database
  - Netowork partitions
  - CAP theorem
  - In more formal terms, if you want to tolerate F number of disconnects (or node failures), you need to have at least 2F + 1 nodes in the cluster. For example, in a cluster of 7 nodes, if more than 3 nodes disconnect, you’ll stop providing service.

  - Summary
    - Distributed systems can improve fault tolerance, eliminating the risk of a single point of failure.
    - Clustering lets you scale out and spread the total load over multiple machines.
    - BEAM-powered clusters are composed of nodes: named BEAM instances that can be connected and can communicate.
    - Two nodes communicate via a single TCP connection. If this connection is broken, the nodes are considered disconnected.
    - The main distribution primitive is a process.
    - Building on top of those primitives, many useful higher-level services are available in the :global, :rpc, and GenServer modules.
    - Always consider and prepare for netsplit scenarios.
