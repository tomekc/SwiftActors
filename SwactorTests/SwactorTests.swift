//
//  SwactorTests.swift
//  SwactorTests
//
//  Created by Tomek on 05.07.2014.
//  Copyright (c) 2014 Tomek Cejner. All rights reserved.
//

import XCTest
import Swactor

class SwactorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    struct CoffeeOrder {
        var name:String
        var expect:XCTestExpectation?
    }
    
    class Barista : Actor {
        let cashier:ActorRef
        
        required init(_ ctx: ActorSystem) {
            cashier = ctx.actorOf(Cashier.self)
            super.init(ctx)
        }
        
        override func receive(message: Any) {
            switch message {
                
            case let order as CoffeeOrder :
                cashier ! Bill(amount: 200, expect:order.expect)
                NSLog ("I am making coffee \(order.name)")
//                order.expect.fulfill()
            default:
                unhandled(message)
            }
        }
    }
    
    struct Bill {
        var amount:Int
        var expect:XCTestExpectation?
    }
    
    class Cashier : Actor {

        required init(_ ctx: ActorSystem) {
            super.init(ctx)
        }
        
        override func receive(message: Any) {
            switch message {
            case let bill as Bill :
                NSLog("Billing $\(bill.amount)")
                bill.expect?.fulfill()
                
            default:
                unhandled(message)
            }
        }
        
    }
    
    func testBasic() {
        
        let acsys = ActorSystem()
        
        let clintEastwood:ActorRef = acsys.actorOf(Barista.self)
        
        clintEastwood ! CoffeeOrder(name:"Latte", expect:expectationWithDescription("Cashier acted"))
        
        waitForExpectationsWithTimeout(10.0, handler: { error in
            NSLog("Done")
            if (error) {
                NSLog("There was error %@",error)
            }
        })
        
    }
    
    func testActorReuse() {
        let acsys = ActorSystem()
        
        let actor1:ActorRef = acsys.actorOf(Barista.self)
        let actor2:ActorRef = acsys.actorOf(Barista.self)
        
        XCTAssertTrue(actor1 === actor2, "Should be same instance")
    }
    
    func testDelayedMessage() {
        let acsys = ActorSystem()
        
        let actor1:ActorRef = acsys.actorOf(Cashier.self)
        
        actor1.tell(Bill(amount: 100, expect: expectationWithDescription("Called after two seconds")), after: 2000)
        
        waitForExpectationsWithTimeout(3.0, handler: { error in
            NSLog("Done waiting for delayed message")
        })
        
    }
}
