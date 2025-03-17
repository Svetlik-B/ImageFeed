import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()

        loginTextField.typeText("email")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        sleep(3)

        passwordTextField.typeText("password")
        webView.swipeUp()

        // Нажать кнопку логина
        webView.buttons["Login"].tap()

        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()

        // Поставить лайк в ячейке верхней картинки
        let likeButton = cellToLike.buttons["No Active"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()

        // Отменить лайк в ячейке верхней картинки
        let unlikeButton = cellToLike.buttons["Active"]
        XCTAssertTrue(unlikeButton.waitForExistence(timeout: 5))
        unlikeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))

        // Нажать на верхнюю ячейку
        cellToLike.tap()
        // Подождать, пока картинка открывается на весь экран
        let navBackButtonWhiteButton = app.buttons["Backward"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))

        let image = app.scrollViews.images.element(boundBy: 0)
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)

        // Вернуться на экран ленты
        navBackButtonWhiteButton.tap()
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
    }

    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        let profileButton = app.buttons["profileTabBarItem"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5))

        // Перейти на экран профиля
        profileButton.tap()
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertEqual(
            app.staticTexts["nameLabel"].label,
            "Bochkareva Svetlana"
        )
        XCTAssertEqual(
            app.staticTexts["loginLabel"].label,
            "@svetlikigorevna"
        )
        
        // Нажать кнопку логаута
        app.buttons["Exit"].tap()
        app.alerts["Пока, пока!"]
            .buttons["Да"].tap()

        // Проверить, что открылся экран авторизации
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
    }
}
