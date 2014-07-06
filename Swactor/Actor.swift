//
//  Actor.swift
//  Swactor
//
//  Created by Tomek on 05.07.2014.
//  Copyright (c) 2014 Tomek Cejner. All rights reserved.
//

import Foundation


class Actor {
    
    var dispatchQueue:dispatch_queue_t?
    var queue: Array<Any>
    var name:String
    
    init() {
        queue = Array()
        self.name = NSString(format: "Actor-%d", rand()) as String
    }
    
    func put(message:Any) {
        queue.insert(message, atIndex: 0)
        act()
    }
    
    func act() {
        while (queue.count > 0) {
            let msg:Any = queue.removeLast()
            dispatch_async(dispatchQueue!) {
                self.receive(msg)
            }
        }
    }
    
    // You shall override this function
    func receive(message:Any) {
        
    }
    
}

class ActorUI : Actor {
    
}


class ActorRef {
    var actor:Actor
    var queue:dispatch_queue_t
    
    init(actor:Actor, queue:dispatch_queue_t) {
        self.actor = actor
        self.actor.dispatchQueue = queue
        self.queue = queue
    }
    
    func accept(message:Any) {
        self.actor.receive(message)
    }
}

class ActorSystem {
   
    var serialQueue:dispatch_queue_t

    init() {
        self.serialQueue =  dispatch_queue_create("net.japko.actor", DISPATCH_QUEUE_SERIAL)
    }
    
    func actorOf(actor:Actor) -> ActorRef {
        let name = "net.japko.actors." + actor.name
        println("Creating actor \(name)")
        
        let queue = dispatch_queue_create(name.bridgeToObjectiveC().UTF8String, DISPATCH_QUEUE_SERIAL)
        
        return ActorRef(actor: actor, queue:queue)
    }
    
}

operator infix ! {}

@infix func ! (left:ActorRef, right:Any) -> Void {
        left.accept(right)
}


