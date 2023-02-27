import Foundation

class QuestionFactory: QuestionFactoryProtocol { //объявление протокола
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    //Метод инициирущий загрузку данных
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return}
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем что данные загруженны
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) //сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in //запуск кода в другом потоке
            // выбираем произвольный элемент из массива
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            //Создание данных из URL
            var imageData = Data() // по умолчанию у нас будут просто пустые данные
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            //создание вопроса, определяем корректность? создаем модель вопроса
            let rating = Float(movie.rating) ?? 0 // превращяем строку в число
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            //возврат после загрузки и обработки в главный поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
}






/*
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
 */
