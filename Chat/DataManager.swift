//
//  DataManager.swift
//  Chat
//
//  Created by Siarhei on 26.01.2020.
//  Copyright © 2020 Siarhei. All rights reserved.
//

import UIKit
import Alamofire


class DataManager {

    // отправляет сообщение на сервер и обрабатывает ответ сервера
    func postMessage(_ parameters: [String : Any], completion: @escaping (Int, String) -> ())  {
        Alamofire.request(api, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in

            if response.result.isFailure {

                let error = response.error?.localizedDescription ?? ""
                completion(1, error)
            }
            else {
                if let data = response.data {

                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())

                        if let responseDic = jsonResponse as? NSDictionary {

                            if responseDic.value(forKey: "status") != nil {

                                let status = responseDic.value(forKey: "status") as! Int
                                if status == 0 {
                                    completion(0, "")
                                }
                                else {
                                    if responseDic.value(forKey: "error") != nil {

                                        let error = responseDic.value(forKey: "error") as! String
                                        completion(1, error)
                                    }
                                }
                            }
                        }
                    }
                    catch _ {
                        completion(1, "Не верный формат JSON")
                    }
                }
            }
        }
    }
}
