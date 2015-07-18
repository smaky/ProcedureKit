//
//  OperationsTests.swift
//  OperationsTests
//
//  Created by Daniel Thorpe on 26/06/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import XCTest

@testable
import Operations

class TestOperation: Operation {
    
    let numberOfSeconds: Double
    let simulatedError: ErrorType?
    var didExecute: Bool = false
    
    init(delay: Int, error: ErrorType? = .None) {
        numberOfSeconds = Double(delay)
        simulatedError = error
    }
    
    override func execute() {
        let after = dispatch_time(DISPATCH_TIME_NOW, Int64(numberOfSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(after, dispatch_get_main_queue()) {
            self.didExecute = true
            self.finish(self.simulatedError)
        }
    }

    func addCompletionBlockToTestOperation(operation: TestOperation, withExpectation expectation: XCTestExpectation) {
        operation.completionBlock = { [weak operation] in
            if let weakOperation = operation {
                XCTAssertTrue(weakOperation.didExecute)
                expectation.fulfill()
            }
        }
    }
}

class TestQueueDelegate: OperationQueueDelegate {

    typealias DidFinishOperation = (NSOperation, [ErrorType]) -> Void

    let didFinishOperation: DidFinishOperation?

    var did_willAddOperation: Bool = false
    var did_operationDidFinish: Bool = false
    var did_numberOfErrorThatOperationDidFinish: Int = 0

    init(didFinishOperation: DidFinishOperation? = .None) {
        self.didFinishOperation = didFinishOperation
    }

    func operationQueue(queue: OperationQueue, willAddOperation operation: NSOperation) {
        did_willAddOperation = true
    }

    func operationQueue(queue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [ErrorType]) {
        did_operationDidFinish = true
        did_numberOfErrorThatOperationDidFinish = errors.count
        didFinishOperation?(operation, errors)
    }
}

class OperationsTests: XCTestCase {
    
    var queue: OperationQueue!
    var delegate: TestQueueDelegate!
    
    override func setUp() {
        super.setUp()
        queue = OperationQueue()
        delegate = TestQueueDelegate()
    }

    override func tearDown() {
        queue = nil
        delegate = nil
        super.tearDown()
    }

    func test__queue_delegate_is_notified_when_operation_starts() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        let operation = TestOperation(delay: 1)
        operation.addCompletionBlockToTestOperation(operation, withExpectation: expectation)

        queue.delegate = delegate
        queue.addOperation(operation)

        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(delegate.did_willAddOperation)
        XCTAssertTrue(delegate.did_operationDidFinish)
    }


    func test__executing_basic_operation() {
        let expectation = expectationWithDescription("Test: \(__FUNCTION__)")

        let operation = TestOperation(delay: 1)
        operation.addCompletionBlockToTestOperation(operation, withExpectation: expectation)

        queue.addOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)
    }





}
