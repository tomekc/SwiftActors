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
    var mailbox: Array<Any>
    var name:String
    var busy:Bool
    
    init() {
        busy = false
        mailbox = Array()
        self.name = NSString(format: "Actor-%d-%f", rand(), NSDate.timeIntervalSinceReferenceDate()) as String
    }
    
    func put(message:Any) {
        dispatch_async(dispatchQueue!) {
            self.receive(message)
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
        self.actor.put(message)
    }
}

class ActorSystem {
    
    func actorOf(actor:Actor) -> ActorRef {
        switch(actor) {
        case is ActorUI:
            return ActorRef(actor: actor, queue: dispatch_get_main_queue())
        default:
            let name = "net.japko.actors." + actor.name
            let queue = dispatch_queue_create(name.bridgeToObjectiveC().UTF8String, DISPATCH_QUEUE_SERIAL)
            
            return ActorRef(actor: actor, queue:queue)
            
        }
    }
    
}

operator infix ! {}

@infix func ! (left:ActorRef, right:Any) -> Void {
    left.accept(right)
}


