import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        //это специальная настройка для тестов: если один тест не прошел,
        //то следующие тесты запускаться не будут: и правда, зачем ждать
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testScreenCast() throws {}

}
