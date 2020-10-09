//
//  ViewController.swift
//  Chat
//
//  Created by Siarhei on 23.01.2020.
//  Copyright © 2020 Siarhei. All rights reserved.
//

import UIKit
import Foundation

class MessageViewController: UIViewController {

    @IBOutlet weak var sendView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var errorAlertSwitch: UISwitch!
    
    var viewModel = MessageViewModel()
    
    var saveBottom: CGFloat = 0
    var tableHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // поле ввода
        sendView.layer.cornerRadius = 4
        sendView.frame.size.width = self.view.bounds.width - 56
        
        self.messageTable.separatorColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // сохраняем первоначальные данные
        tableHeight = self.messageTable.bounds.height
        saveBottom = bottomLayoutConstraint.constant
    }

    @objc internal func keyboardWillShow(_ notification : Notification?) {
        sendView.becomeFirstResponder()
        if let keyboardFrame: NSValue = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let bottomSafe = self.view.safeAreaInsets.bottom
            self.bottomLayoutConstraint.constant = keyboardRectangle.height - bottomSafe
            UIView.animate(withDuration: 2) {
                self.view.layoutIfNeeded()
            }
            self.scrollToBottom(self.bottomLayoutConstraint.constant)
        }
    }
    
    @objc internal func keyboardWillHide(_ notification : Notification?) {
        bottomLayoutConstraint.constant = saveBottom
    }
       
    // показывает сообщение
    func showAlert(_ title: String, message: String) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        let closeAction = UIAlertAction(title: "ОК",
                                        style: UIAlertAction.Style.default)
        alertController.addAction(closeAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // обрабатываем отправку сообщения
    @IBAction func sendMessageTapped(_ sender: Any) {
        
        if sendView.text.count > 0 {
            
            viewModel.fetch(sendView.text) { [weak self] (status, error) in
                if status != 0 && self?.errorAlertSwitch.isOn ?? false {
                    self?.showAlert("Сообщение не отправлено", message: "Ошибка: \(error)")
                }
                self?.messageTable.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self?.scrollToBottom()
                }
            }
            sendView.text = ""
        }
        sendView.resignFirstResponder()
        
        // приводим поле ввода в исходное состояние
        var frame = sendView.frame
        frame.size.height = 34
        sendView.frame = frame
        bottomViewHeight.constant = sendView.bounds.size.height + 10
    }
}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return viewModel.messages[indexPath.row].size.height + bottomSpace
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTable.dequeueReusableCell(withIdentifier: "MessageViewCell", for: indexPath) as! MessageViewCell
        cell.message.text = viewModel.messages[indexPath.row].text
        cell.time.text = viewModel.messages[indexPath.row].time
        
        cell.widthLayoutConstraint.constant = viewModel.messages[indexPath.row].size.width
        cell.heightLayoutConstraint.constant = viewModel.messages[indexPath.row].size.height

        return cell;
    }
    
    // вычисляет текущую высоту контента
    func getHightContent() -> CGFloat {
        
        var hightContent: CGFloat = 0
        for i in 0..<viewModel.messages.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = messageTable.cellForRow(at: indexPath) as? MessageViewCell
            hightContent += (cell?.heightLayoutConstraint.constant ?? 0) + bottomSpace
        }
        return hightContent
    }
    
    // сравнивает текущую высоту контента с текущей высотой таблицы, если высота контента меньше высоты таблицы смещаем контент на разницу высот
    func scrollToBottom(_ offset: CGFloat = 0) {

        let hightContent = getHightContent()
        if hightContent < tableHeight - offset {
            let contentInset = tableHeight - hightContent - offset
            self.messageTable.contentInset.top = contentInset
        }
        else {
            self.messageTable.contentInset.top = 0
        }
        let indexPath = IndexPath(row: viewModel.messages.count-1, section: 0)
        if indexPath.row >= 0 {
            self.messageTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension MessageViewController: UITextViewDelegate {
    
    // ограничиваем максимальную длину сообщения в 255 символов
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if sendView.text.count <= 255 {
            return true
        }
        else {
            return false
        }
    }
    
    // ограничиваем поле ввода по высоте (не более 5 строк)
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.numberOfLines <= 5 {
            var frame = textView.frame
            if textView.numberOfLines == 1 {
                frame.size.height = 34
            }
            else {
                frame.size.height = CGFloat(18 * textView.numberOfLines)
            }
            textView.frame = frame
            bottomViewHeight.constant = textView.bounds.size.height + 10
        }
    }
}

extension UITextView {
    
    // вычисляет количество строк в поле ввода
    var numberOfLines: Int {
        let numberOfGlyphs = self.layoutManager.numberOfGlyphs
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
            self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
          index = NSMaxRange(lineRange)
          numberOfLines += 1
        }

        return numberOfLines
    }
}
