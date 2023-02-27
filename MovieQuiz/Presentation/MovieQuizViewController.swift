import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
        
    
    // MARK: - Properties
    
    private var questionFactory: QuestionFactory? // фабрика вопросов, за вопросами обращаемся к ней
    private var currentQuestion: QuizQuestion? // текущий вопрос который видит пользователь
    private var alertPresenter: AlertPresenterDelegate?
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
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
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
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
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
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.unlockButton()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
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
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") {
            [weak self] in guard let self = self else {return}
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(model: alert)
    }
    
    // MARK: showNextQuestionOrResults
   
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else {return}
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let totalAccuracy = "\(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
            let bestGameTime = statisticService.bestGame.date.dateTimeString
            let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let text = """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(bestGameStats) (\(bestGameTime))
                        Средняя точность: \(totalAccuracy)
                        """
            let alert = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз") { [weak self] in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            alertPresenter?.show(model: alert)
            noButton.isEnabled = true
            yesButton.isEnabled = true
        } else {
            noButton.isEnabled = true
            yesButton.isEnabled = true
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
}








