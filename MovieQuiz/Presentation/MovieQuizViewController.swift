import UIKit

final class MovieQuizViewController: UIViewController {
  
    
    private var currentQuestionIndex : Int = 0
    private var correctAnswers : Int = 0
    
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
       
    //Статус бар в белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Изображение создано и готово к показу
   override func viewDidLoad() {
        super.viewDidLoad()
        //показ первого вопроса
       if let firstQuestion = QuestionFactory.requestNextQuestion() {
           currentQuestion = firstQuestion
           let viewModel = convert(model: firstQuestion)
           show(quiz: viewModel)
       }
    }
     
    
    @IBOutlet private var imageView: UIImageView! //изображение фильма
    
    @IBOutlet private var textLabel: UILabel! //текст вопроса
    
    @IBOutlet private var counterLabel: UILabel! // счетчик вопросов counterLabel
    
    // Функции кнопок
    // Нажатие кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = false
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
        
    }
    //  Нажатие кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = true
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    // здесь мы заполняем нашу картинку, текст и счётчик данными
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //здесь мы показываем результат прохождения квиза
    private func show(quiz result: QuizResultsViewModel){
        let alert = UIAlertController(
            title: result.title, message: result.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            
            //счетчик правильных ответов в 0
            self.correctAnswers = 0
            
            // Заново показываем первый вопрос
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Функция конвертации из QuizQuestion в QuizStepViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }
    
    //состояние показа результата ответа
    private func showAnswerResult(isCorrect: Bool) {
        //счетчик правильных ответов
        if isCorrect {
            correctAnswers += 1
        }
        //Рамки в зеленый
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Запуск следующего вопроса через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    //показ следующего вопроса или результата
    private func showNextQuestionOrResults(){
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, Вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен", text: text, buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1 // увеличим индекс вопроса на + 1
            // показать вопрос
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
        }
    }
}

