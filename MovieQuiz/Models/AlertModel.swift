//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by m.daudov on 26.09.2022.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
