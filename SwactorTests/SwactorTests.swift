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
        var expect:XCTestExpectation
    }
    
    class Barista : Actor {
        var cashier:ActorRef
        
        init(context:ActorSystem) {
            cashier = context.actorOf(Cashier.self)
            super.init(context)
        }
        
        override func receive(message: Any) {
            dump(message)
            switch message {
                
            case let order as CoffeeOrder :
                cashier ! Bill(amount: 200)
                order.expect.fulfill()
                NSLog ("I am making coffee \(order.name)")
            default:
                unhandled(message)
            }
        }
    }
    
    struct Bill {
        var amount:Int
    }
    
    class Cashier : Actor {
        override func receive(message: Any) {
            switch message {
            case let bill as Bill :
                NSLog("Billing for \(bill.amount)")
            default:
                unhandled(message)
            }
        }
        
    }
    
    func testBasic() {
        let expectation = expectationWithDescription("Cashier actor called")
        
        let acsys = ActorSystem()
        
        let clintEastwood:ActorRef = acsys.actorOf(Barista.self)
        
        NSLog("Created actor named: %@", clintEastwood.name)
            
        clintEastwood ! CoffeeOrder(name:"Latte", expect:expectation)
        clintEastwood ! CoffeeOrder(name:"Mocha", expect:expectation)
        clintEastwood ! Bill(amount: 999)
        
        waitForExpectationsWithTimeout(10, handler: { error in
            //
            NSLog("There was error")
        })

    }
}
