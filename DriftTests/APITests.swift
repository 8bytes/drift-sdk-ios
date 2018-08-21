//
//  APITests.swift
//  Drift
//
//  Created by Eoin O'Connell on 04/03/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import Drift


class APITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Drift.logout()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAuth() {
        
        let testExpectation = expectation(description: "API Will call Auth")
        
        let embed = Mapper<Embed>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.embedJSONCorrect)!)

        XCTAssertNotNil(embed)
        DriftDataStore.sharedInstance.setEmbed(embed!)
        
        DriftManager.getAuth("eoin+app@8bytes.ie", userId: "123743810") { (success) -> () in
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (_) -> Void in
            XCTAssertNotNil(DriftDataStore.sharedInstance.auth)
        }
    }
    
    
    func testEmbed(){
        
        let testExpectation = expectation(description: "API Will call Embed")

        DriftManager.getEmbedData("u4r5t7h6w6h5-dev") { (success) -> () in
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (_) -> Void in
            XCTAssertNotNil(DriftDataStore.sharedInstance.embed)
        }
        
    }
    
}
