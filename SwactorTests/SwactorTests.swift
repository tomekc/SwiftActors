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

    
    
    class CoffeeOrder {
        var name:String?
    }
    
    class Barista : Actor {
        override func receive(message: AnyObject) {
            switch message {
                
            case let order as CoffeeOrder :
                NSLog ("I am making coffee \(order)")
            default:
                NSLog("Dupa")
                
            }
        }
    }
    
    
    func testBasic() {
        
        let acsys = ActorSystem()
        
        let actorek:ActorRef = acsys.actorOf(Barista())
        actorek ! CoffeeOrder()
        
    }
}
