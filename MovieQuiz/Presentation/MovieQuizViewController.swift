import UIKit

import UIKit

protocol MovieQuizViewProtocol: AnyObject {
    func show(quiz: QuizStepViewModel)
    func highLightImageBorder(isCorrect: Bool)
    func setupActivityIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func finishAlert()
    func blockingButton()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    @IBOutlet private var imageView: UIImageView! //изображение фильма
    @IBOutlet private var textLabel: UILabel! //текст вопроса
    @IBOutlet private var counterLabel: UILabel! // счетчик вопросов counterLabel
    @IBOutlet private var noButton: UIButton! // кнопка НЕТ
    @IBOutlet private var yesButton: UIButton! // кнопка ДА
    @IBOutlet private var questionLabelText: UILabel!
    @IBOutlet private var indexQuestionText: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .ypBlack
        activityIndicator.startAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    func blockingButton() {
        self.noButton.isEnabled.toggle()
        self.yesButton.isEnabled.toggle()
    }
    
    func showQuizResult(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) { _ in model.completion()}
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        alert.view.accessibilityIdentifier = "alert"
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        UIView.transition(with: imageView,
                          duration: 0.3,
                          animations: {self.imageView.image = step.image })
    }
    
    func finishAlert() {
        let message = presenter.makeResultMessage()
        let alert = AlertModel(title: "Этот раунд окончен!",
                               message: message,
                               buttonText: "Сыграть еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alertPresenter?.show(model: alert)
    }
    
    func highLightImageBorder(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") {
            [weak self] in guard let self = self else {return}
            self.presenter.restartGame()
        }
        alertPresenter?.show(model: alert)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenterDelegate()
        alertPresenter?.didLoad(self)
    }
}

