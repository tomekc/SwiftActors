//
//  Actor.swift
//  Swactor
//
//  Created by Tomek on 05.07.2014.
//  Copyright (c) 2014 Tomek Cejner. All rights reserved.
//

import Foundation


public class Actor {
    
    var dispatchQueue:dispatch_queue_t?
    var mailbox: Array<Any>
    var name:String
    var busy:Bool
    let context:ActorSystem
    
    required public init(_ ctx:ActorSystem) {
        busy = false
        mailbox = Array()
        self.name = NSString(format: "Actor-%d-%f", rand(), NSDate.timeIntervalSinceReferenceDate()) as String
        context = ctx
    }
    
    func put(message:Any) {
        dispatch_async(dispatchQueue!) {
            self.receive(message)
        }
    }
    
    public func unhandled(message:Any) {
        
    }
    
    // You shall override this function
    public func receive(message:Any) {
        
    }
    
}

public class ActorUI : Actor {
    
}


public class ActorRef : Printable {
    var actor:Actor
    var queue:dispatch_queue_t
    
    public var description: String { get {
        return "<ActorRef name:"+actor.name + ">"
        }
    }
    
    public var name:String {
        get {
            return actor.name
        }
    }
    
    init(actor:Actor, queue:dispatch_queue_t) {
        self.actor = actor
        self.actor.dispatchQueue = queue
        self.queue = queue
    }
    
    func accept(message:Any) {
        self.actor.put(message)
    }
    
}

public class ActorSystem {
    
    public init() {
        
    }
    
    public func actorOfInstance(actor:Actor) -> ActorRef {
        switch(actor) {
        case is ActorUI:
            return ActorRef(actor: actor, queue: dispatch_get_main_queue())
        default:
            let name = "net.japko.actors." + actor.name
            
            let queue = dispatch_queue_create(name.cStringUsingEncoding(NSUTF8StringEncoding)!, DISPATCH_QUEUE_SERIAL)
            
            return ActorRef(actor: actor, queue:queue)
            
        }
    }
    
    public func actorOf<T : Actor>(actorType:T.Type) -> ActorRef {
        
        let actor:T = actorType(self)
        let queueName = "net.japko.actors." + actor.name
        
        let queue = dispatch_queue_create(queueName.cStringUsingEncoding(NSUTF8StringEncoding)!, DISPATCH_QUEUE_SERIAL)
        return ActorRef(actor: actor, queue:queue)
    }
    
    
    
}

infix operator  ! {}

public func ! (left:ActorRef, right:Any) -> Void {
    left.accept(right)
}


