import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get } // новый тип данных GameRecord, нужен, чтобы записывать в него результат одной игры и сохранять его в User Defaults.
    
}

