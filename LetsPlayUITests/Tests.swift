//
//  Tests.swift
//  LetsPlayUITests
//

import XCTest

class Tests: XCTestCase {
        
    func testAllControlsAppearWhenQuestionIsProvided() {
        /*
         Verify that all elements are visible in the Quiz screen.
         For example, verify that point label, question label, all 4 buttons and close button is there.
         */
    }

    func testNewQuestionChangesQuestionLabelAndAnswerButtons() {
        /*
         Verify that when a new question is provided, the question label and answer buttons are updated.
         */
    }

    func testButtonsAreDisabledAfterAnsweringAndAgainEnabledAfterQuestionChanges() {
        /*
         Verify that when a question is answered, all answer buttons are disabled until the next question is provided.
         */
    }

    func testCloseBySwiping() {
        /*
         Verify that it is possible to close Quiz screen just by swiping it away (from top to bottom).
         */
    }

    func testCloseByTappingAButton() {
        /*
         Verify that it is possible to close Quiz screen just by tapping on the Close button.
         */
    }

    func testTappingOnCorrectAnswerIncreasesThePointsLabelBy1() {
        /*
         Verify that if user taps on the correct answer button, the points label is increased by 1.
         For example, "0 / 1" -> "1 / 1"
         */
    }

    func testQuizStartTime() {
        /*
         Verify that the quiz start time is in the correct format and is displaying current time.
         */
    }

    func testLocationPermissionAllowedShowsTheQuizButton() {
        /*
         Verify that when the user accepts the location permission, the Quiz button is visible.
         */
    }

    func testLocationPermissionDeclinedShowsWarning() {
        /*
         Verify that when the user declines the location permission, the Quiz button is
         not visible and the warning message is shown to user.
         */
    }

    func testLocationDetectionProcess() {
        /*
         Verify that when the user accepts the location permission, the app shows:
            a) label that informs about location detection.
            b) after that shows the current city name.
            c) and also shows the Quiz button.
         */
    }
    

//MARK: - Supporting Methods

    private enum LocationPermission: String {
        case allowOnce = "Allow Once"
        case alwaysAllow = "Allow While Using App"
        case dontAllow = "Don’t Allow"
    }
    
    private func resetLocationWarnings(for app: XCUIApplication) {
        app.terminate()
        XCUIDevice.shared.press(.home)
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        
        let settingsIcon = springboard.icons["Settings"]
        if settingsIcon.exists {
            settingsIcon.tap()
            settings.tables.staticTexts["General"].tap()
            settings.tables.staticTexts["Reset"].tap()
            settings.tables.staticTexts["Reset Location & Privacy"].tap()
            settings.buttons["Reset Warnings"].tap()
            settings.terminate()
        }
    }
    
    

    private func setupAppWith(locationPermission: LocationPermission) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        
        let _ = addUIInterruptionMonitor(withDescription: "Location Permission Alert") { (alert: XCUIElement) -> Bool in
            XCTAssert(alert.exists)
            alert.buttons[locationPermission.rawValue].tap()
            return true
        }
        app.tap()
        
        return app
    }
    
    private func quizButtonExists(for app: XCUIApplication) -> Bool {
        let quizButtonExists = app.buttons["Quiz"].waitForExistence(timeout: 5)
        XCTAssert(quizButtonExists)
        return quizButtonExists
    }
}
