//
//  MessageViewModel.swift
//  Chat
//
//  Created by Siarhei on 26.01.2020.
//  Copyright © 2020 Siarhei. All rights reserved.
//

import UIKit
import CommonCrypto

class MessageViewModel {

    var messages: [Message] = []
    
    private let dataManager = DataManager()
    
    // заносит данные о сообщении в массив и отправляет сообщение на сервер
    func fetch(_ text: String, completion: @escaping (Int, String) -> ()) {

        let mesage = Message()
        
        mesage.text = text
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        mesage.time = timeFormatter.string(from: Date())
        
        let maxWidth:CGFloat = UIScreen.main.bounds.width
        let textLabel = InsetLabel()
        textLabel.text = text
        textLabel.font = textFont
        textLabel.numberOfLines = 0
        mesage.size = textLabel.sizeThatFits(CGSize(width: maxWidth * 2 / 3, height: heightText))

        let md5 = "\(text)John Smith".md5()
        let parameters = ["func" : "send_msg", "txt" : text, "nm" : "John Smith", "user_key" : md5] as [String : Any]

        dataManager.postMessage(parameters) { [weak self] (status, error) in
            self?.messages.append(mesage)
            completion(status, error)
        }
    }
}


extension String {
    func md5() -> String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
    
