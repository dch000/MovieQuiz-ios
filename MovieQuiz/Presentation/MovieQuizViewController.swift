import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactory? // фабрика вопросов, за вопросами обращаемся к ней
    private var currentQuestion: QuizQuestion? // текущий вопрос который видит пользователь
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10 //количество вопросов для квиза
    
    
    @IBOutlet private weak var imageView: UIImageView! //изображение фильма
    @IBOutlet private weak var textLabel: UILabel! //текст вопроса
    @IBOutlet private weak var counterLabel: UILabel! // счетчик вопросов counterLabel
    @IBOutlet private weak var noButton: UIButton! // кнопка НЕТ
    @IBOutlet private weak var yesButton: UIButton! // кнопка ДА
    @IBOutlet private weak var questionLabelText: UILabel!
    @IBOutlet private weak var indexQuestionText: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    //Статус бар в белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Изображение создано и готово к показу
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    
    
    // MARK: - Actions
    // Нажатие кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = false
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
        blockButton()
    }
    //  Нажатие кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let giveAnswer = true
        showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            
        }
    }
    
    // MARK: - Private Functions
    
    private func unlockButton() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    private func blockButton() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
        
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return } // optional weak link is commonly deployed
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.unlockButton()
        }
    }
        
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // отключаем анимацию
    }
        
    private func showNetworkError(message: String) {
        hideLoadingIndicator() //скрываем индикатор загрузки
        
        // создайте и покажите алерт
        let model = AlertModel (title: "Ошибка",
                                message: message,
                                buttonText: "Попробовать еще раз", completion: { [weak self] in guard let self = self else {return}
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.showQuizResult(model: model)
    }
    
    // MARK: showNextQuestionOrResults
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            imageView.layer.borderWidth = 8
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let bestGame = statisticService?.bestGame else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            // QuizResultViewModel
            
            let finalScreen = AlertModel (title: "Этот раунд окончен!",
                                          message: """
                                          Ваш результат: \(correctAnswers)/\(questionsAmount)
                                          Количество сыгранных квизов: \(gamesCount)
                                          Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                                          Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                                          """ ,
                                          buttonText: "Сыграть еще раз",
                                          completion: { [weak self] in
                guard let self = self else { return }
                self.imageView.layer.borderWidth = 0
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.showQuizResult(model: finalScreen)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}








