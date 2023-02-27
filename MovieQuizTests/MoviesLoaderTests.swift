import Foundation
import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccesLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) //говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies {result in
            //then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                //мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Unexpected failure") // эта функция провалила тест
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    
    func testFailureLoading() throws {
        //Given
        
        //When
        
        //Then
        
    }
}
