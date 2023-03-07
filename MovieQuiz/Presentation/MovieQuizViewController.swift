import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
        
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion? // текущий вопрос который видит пользователь
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    //private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    //private let questionsAmount: Int = 10 //количество вопросов для квиза
    private let presenter = MovieQuizPresenter()
    
    
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
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
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
        blockButton()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
  
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
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
     
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // отключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true // скрываем индикатор загрузки

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        alert.addAction(action)
    }
   
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            unlockButton()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            unlockButton()
        }
    }
    
}








