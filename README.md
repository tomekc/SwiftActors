# Actors in Swift

This is an approach to implement actor model of concurrency in Swift.

What's included:

  * simple inbox based on Array
  * serial GCD dispatch queue, created separately for each actor
  * use **!** operator to send a message
  * messages can be anything, *structs* preferred
  
See *SwactorTests.swift* for example usage.

### Contact me

   * [@tomekcejner](http://twitter.com/tomekcejner) on Twitter
   * email tomek at japko dot info
   