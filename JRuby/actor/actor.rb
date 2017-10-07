require 'java'
require './scala-library-2.11.4.jar'
require './config-1.3.1.jar'
require './akka-actor_2.11-2.5.3.jar'

java_import 'java.io.Serializable'
java_import 'akka.actor.UntypedActor'
java_import 'akka.actor.ActorRef'
java_import 'akka.actor.ActorSystem'
java_import 'akka.actor.Props'
java_import 'akka.actor.Deploy'

class Greeting
  include Serializable

  attr_reader  :who

  def initialize(who)
    @who = who
  end
end

class GreetingActor < UntypedActor
  def onReceive(message)
    puts "Hello " + message.who
  end
end

system = ActorSystem.create("GreetingSystem")
props = Props[GreetingActor.class]

greeter = system.actorOf(props, "greeter")
greeter.tell(Greeting.new("Anil Wadghule"))

system.shutdown
system.await_termination