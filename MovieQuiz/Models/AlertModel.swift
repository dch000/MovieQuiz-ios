import UIKit

struct AlertModel {
    let title: String //текст заголовка алерта
    let message: String // текст сообщения алерта
    let buttonText: String // текст для кнопки аллерта
    let comletion: (() -> ()) // замыкание для параметров для действия по кнопке алерта
}

