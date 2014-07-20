# Actors in Swift

This is an approach to implement actor model of concurrency in Swift.

What's included:

  * simple inbox based on Array
  * serial GCD dispatch queue, created separately for each actor
  * use **!** operator to send a message
  * messages can be anything, *structs* preferred
  
See *SwactorTests.swift* for example usage.

## What are actors?

Actor model is an approach to concurrency known in Erlang, and implemented in Scala. For JVM there is popular framework, [Akka](http://www.akka.io)

Actor model is an approach to make massive concurrency much easier by eliminating locking and synchronization, which is hard to master and may lead to difficult to detect bugs.

Altough iOS apps are not going to tackle such problems, I found actors as a interesting abstraction over concurrent computation. 

In a nutshell, actor is a small task processor with inbox to which it is accepting messages. This is why sometimes actor model is called *message-passing style of concurrency*. Messages are sent asynchronously, but actor is processing them one at time. Processing outcome is usually sending a message to another actor, and so on.
Most likely, last actor in "chain" will be responsible for output.

Messages sent to actors are (should be) immutable, so Swift's struct are good fit, making syntax similar to Scala's case classes.

Actors can handle any type of message, and Swift's pattern matching (just like in Scala) is used inside actor.

Actors are created by extending **Actor** or **ActorUI** class and overriding `receive(message: Any)` method.

## Example project

Look at [Example weather iOS app](https://github.com/tomekc/SwiftActorWeather)

### Contact me

   * [@tomekcejner](http://twitter.com/tomekcejner) on Twitter
   * email tomek at japko dot info
   