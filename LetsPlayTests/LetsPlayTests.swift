//
//  LetsPlayTests.swift
//  LetsPlayTests
//
//  Created by Levandovskis, Nils on 13/11/2023.
//

import XCTest
import AmazonIVSPlayer

final class LetsPlayTests: XCTestCase {

    override func setUp() {/*I'm triggered first before test*/}
    override func setUpWithError() throws {/*I'm triggered second before test*/}
    override func tearDown() {/*I'm triggered first after test*/}
    override func tearDownWithError() throws {/*I'm triggered second after test*/}

    func testExampleTest() {
        let pc = PlayerController()
        let callbackExpectation = expectation(description: "I will be fulfilled when the state change callback is triggered")
        pc.didChangeStateHook = { state in
            // This will only validate that the callback has been called. In the other tests, you can use this hook to validate that state == something before fulfilling the expectation
            callbackExpectation.fulfill()
        }
        pc.loadStream() // notice how we set the hook before calling the method. This way we can be sure we didn't miss a callback while we assign the hook
        wait(for: [callbackExpectation], timeout: 10) // wait for 10 seconds
    }
    
    func testCheckPlayerReachesConnectingState() throws {
        // After loading stream URL, check that player reaches CONNECTING state
    }
    
    func testCheckPlayerReachesConnectedState() throws {
        // After loading stream URL, check that player reaches CONNECTED state
    }
    
    func testCheckPlayerDurationIsChanged() throws {
        // After loading stream URL, check that player duration is updated (should be -1 for livestreams)
    }
    
    func testCheckPlayerReachesIdleState() throws {
        // After loading stream URL, and connecting, check that player reaches IDLE state after pausing
    }
    
    func testCheckPlayerReceivesTextCues() throws {
        // After loading & connecting to stream URL, check that player receives IVSCues of type IVSTextMetadataCue
    }
}
