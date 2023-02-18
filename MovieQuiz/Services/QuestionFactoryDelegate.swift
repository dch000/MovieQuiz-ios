import Foundation

protocol QuestionFactoryDelegate: AnyObject { // Создаём протокол QuestionFactoryDelegate, который будем использовать в фабрике как делегата.
    func didRecieveNextQuestion(question: QuizQuestion?) // Объявляем метод, который должен быть у делегата фабрики.
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}

