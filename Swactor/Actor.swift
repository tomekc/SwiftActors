//
//  Actor.swift
//  Swactor
//
//  Created by Tomek on 05.07.2014.
//  Copyright (c) 2014 Tomek Cejner. All rights reserved.
//

import Foundation


open class Actor {
    
    var dispatchQueue:DispatchQueue?
    var mailbox: Array<Any>
    var name:String
    var busy:Bool
    let context:ActorSystem
    
    required public init(_ ctx:ActorSystem) {
        busy = false
        mailbox = Array()
        self.name = String(format: "Actor-%d-%f", arc4random(), Date.timeIntervalSinceReferenceDate)
        context = ctx
    }
    
    func put(_ message:Any) {
        if let dispatchQueue = self.dispatchQueue {
            dispatchQueue.async {
                self.receive(message)
            }
        } else {
            // FIXME: send error report
            print("self.dispatchQueue is nil")
        }

    }
    
    func put(_ message:Any, after:Int64) {
        let when = DispatchTime.now() + Double(after * 1000000) / Double(NSEC_PER_SEC)
        
        if let dispatchQueue = self.dispatchQueue {
            dispatchQueue.asyncAfter(deadline: when) {
                self.receive(message)
            }
        } else {
            // FIXME: send error report
            print("self.dispatchQueue is nil")
        }
    }
    
    /**
        No-op function which eats unhandled message.
    */
    open func unhandled(_ message:Any) {
    }
    
    // You shall override this function
    open func receive(_ message:Any) {
        
    }
    
}

open class MainThreadActor : Actor {
    
}


open class ActorRef : CustomStringConvertible {
    open let actor:Actor
    var queue:DispatchQueue
    
    open var description: String { get {
        return "<ActorRef name:"+actor.name + ">"
        }
    }
    
    open var name:String {
        get {
            return actor.name
        }
    }
    
    init(actor:Actor, queue:DispatchQueue) {
        self.actor = actor
        self.actor.dispatchQueue = queue
        self.queue = queue
    }
    
    /**
        Send message to actor and return immediately.
    
        :param: message Message object (or structure) to be sent.
    */
    open func tell(_ message:Any) {
        self.actor.put(message)
    }

    /**
        Send message to actor and return immediately. Message will be inserted into dispatch queue
        after given amount of milliseconds.

        :param: message Message object (or structure) to be sent.
        :param: after Delay in milliseconds.

    */
    open func tell(_ message:Any, after:Int64) {
        self.actor.put(message, after: after)
    }
    
}

open class ActorSystem {
    
    var allActors:Dictionary<String, ActorRef> = [:]

    public init() {
    }
    
    func actorOfInstance(_ actor:Actor) -> ActorRef {
        switch(actor) {
        case is MainThreadActor:
            return ActorRef(actor: actor, queue: DispatchQueue.main)
        default:
            let name = "net.japko.actors." + actor.name
            
            // init(label: String, qos: DispatchQoS = default, attributes: DispatchQueue.Attributes = default, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = default, target: DispatchQueue? = default)
            let queue = DispatchQueue(label: name, attributes: [])
            
            return ActorRef(actor: actor, queue:queue)
            
        }
    }
    
    /**
        Creates or retrieves cached instance of actor of given class.
    
        :param: actorType Class of actor, should be child of Actor.
    */
    open func actorOf<T : Actor>(_ actorType:T.Type) -> ActorRef {
        let typeName = NSStringFromClass(T.self)
        
        if let cachedActor = allActors[typeName] {
            return cachedActor
        } else {
            let actor:T = actorType.init(self)
            let reference = actorOfInstance(actor)
            allActors[typeName] = reference
            return reference
        }
    }
    
    
    
}

infix operator  !

public func ! (left:ActorRef, right:Any) -> Void {
    left.tell(right)
}


