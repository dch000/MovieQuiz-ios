import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    //Изображение создано и готово к показу
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         заполнение view данными
         */
    }
    
    // View собираются показать
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         тут имеет смысл дополнительно настроить наши изображения, например задать цвет фона
         */
    }
    
    // View уже показали
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         тут имеет смысл собирать аналитику когда экран показали
         */
    }
    
    // view собираются перестать показывать
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         тут имеет смысл остановить все процессы происходившие на экране
         */
    }
    
    // view перестали показывать
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /*
         Тут имеет смысл оповестить систему аналитики, что экран перестал показываться и привести его в изначальное состояние.
         */
    }
    
    // Реализация логики приложения
    struct QuizQuestion {
      let image: String
      let text: String
      let correctAnswer: Bool
    }
    
    private let questions : [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)]
    
    
    @IBOutlet private var imageView: UIImageView! //изображение фильма
    @IBOutlet private var textLabel: UILabel! //текст вопроса
    @IBOutlet private var counterLabel: UILabel! // счетчик вопросов
    // Функции кнопок
    // Нажатие кнопки НЕТ
    @IBAction func noButtonClicked(_ sender: UIButton) {
    }
    //  Нажатие кнопки ДА
    @IBAction func yesButtonClicked(_ sender: UIButton) {
    }
}





/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
