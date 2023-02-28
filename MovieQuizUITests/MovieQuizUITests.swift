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
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] //находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() //находим кнопку ДА и нажимаем ее
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"] //еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData) //проверяем что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] //находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() //находим кнопку НЕТ и нажимаем ее
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"] //еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData) //проверяем что постеры разные
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(3)
        for _ in 1...10{
            app.buttons["No"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }

}
