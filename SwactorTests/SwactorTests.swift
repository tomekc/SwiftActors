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
    }
    
    class Barista : Actor {
        var cashier:ActorRef
        
        init(cashier:ActorRef) {
                self.cashier = cashier
        }
        
        override func receive(message: Any) {
            switch message {
                
            case let order as CoffeeOrder :
                cashier ! Bill(amount: 200)
                NSLog ("I am making coffee \(order.name)")
            default:
                NSLog("Dupa")
                
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
                NSLog("Dupa")
            }
        }
        
    }
    
    func testBasic() {
        
        let acsys = ActorSystem()
        
        let clerk = acsys.actorOf(Cashier())
        
        let clintEastwood:ActorRef = acsys.actorOf(Barista(cashier:clerk))
        clintEastwood ! CoffeeOrder(name:"Latte")
        clintEastwood ! CoffeeOrder(name:"Mocha")    
        
    }
}
