
# Elixir Basics

### Introduction
- Elixir runs on BEAM VM
- Developed by Ericsson
- Erlang is battle tested and been around for 30 years
- Elixir is purely functional language
- Immutable by default
- Features are Inspired by many programming lunges
- Powerful macro system
- Focuses on scalability, concurrency and fault tolerance
- OTP library and architecture helps for creating fault tolerant systems
- Dynamically typed
- No objects, no classes, no inheritance.
- Useful for
    - Network related tasks (from plain sockets to web servers and frameworks)
    - Writing reliable, distributed and highly concurrent software
    - Uses all cores of computer
- What Elixir adds to Erlang
    - Modules for name spacing
    - Macros
    - A focus on tooling
    - Nicer string handling
    - Consistent function parameters
    - Clearer organization of standard library
    - Variable re-binding
- Highlights
    - Mix - Project management tool
    - First class documentation and doctests
    - Toll free calling of Erlang functions
    - Macros & Pipeline operator
    - Protocols

### Data types
- Atom
- PIDs
- Integers
- Floats
- Tuples
- Keyword Lists
- Characters
- Character lists
- Strings
- Maps
- Structs
- Dicts

#### Truth table
`false` and `nil` are only false and everything else is truthy such as `''` or `[]`


### Atom
Similar to Ruby symbols
e.g. `:ok`, `:foo`


### Strings
str = "Hello World”

###  Tuples
`{:ok, 1, "data"}`


#### Lists
```
list = [ 1, "data”, :ok, {"a”} ]
```
`hd(list)`
`tl(list)`

### Keyword Lists
```
data = [name: "Jon”, language: "Elixir”]
	data[:name] returns "Jon"
	data[:language]
 	ArgumentError
```

### Maps
```
data = %{name: "Jon", language: "Elixir"}
data.name "Jon"
data[:language]` "Elixir"
```

###### PIDS
They are first class


###### Structs

```
defmodule User do
  defstruct name: "John", age: 27
end
%User{}
```

```
=\> %User{age: 27, name: "John"}
```

```
%User{name: "Meg"}
```
```
=\> %User{age: 27, name: "Meg"}
```

###### Ranges

```
(1..5) 
```

###### Interoperability with Erlang
- erl

```
`os:timestamp().
```

- iex

```
:os.timestamp
```

### Pattern matching

### Deconstruction

### Pattern matching

### Functions

### Inline functions

### Enum

### Named functions

### Multiple clauses

### Pipeline operator

### Streams

### Protocols

### Macros

### Processes
- spawn
- agents

### Actor model

### Lightweight processes
- Are applications
- Requires minimum of 2K of memory
- Are supervised
- Fault-tolerant
- Garbage collected environment
- Runs on Multicore machines
