import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        // TODO: удалить
        loginTextField.typeText("login")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        sleep(3)
        // TODO: удалить
        passwordTextField.typeText("password")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))

        let likeButton = cellToLike.buttons["No Active"]
        let unlikeButton = cellToLike.buttons["Active"]
        
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        
        XCTAssertTrue(unlikeButton.waitForExistence(timeout: 5))
        unlikeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        cellToLike.tap()
        let navBackButtonWhiteButton = app.buttons["Backward"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        navBackButtonWhiteButton.tap()
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
    }
}
