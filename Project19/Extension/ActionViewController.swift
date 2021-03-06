//
//  ActionViewController.swift
//  Extension
//
//  Created by Ivan Ivanušić on 20/09/2020.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let preloadedScrips = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(loadScripts))
        
        navigationItem.rightBarButtonItems = [doneButton, preloadedScrips]

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func loadScripts() {
        let ac = UIAlertController(title: "Select preloaded script:", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Alert test", style: .default, handler: alertTestAction))
        ac.addAction(UIAlertAction(title: "Alert warning", style: .default, handler: alertWarningAction))
        ac.addAction(UIAlertAction(title: "Alert HelloWorld", style: .default, handler: alertHelloWorldAction))
        
        present(ac, animated: true)
    }
    
    func alertTestAction(action: UIAlertAction) {
        script.text = """
            alert("Test")
            """
        reloadInputViews()
    }
    
    func alertWarningAction(action: UIAlertAction) {
        script.text = """
            alert("Warning")
            """
        reloadInputViews()
    }
    
    func alertHelloWorldAction(action: UIAlertAction) {
        script.text = """
            alert("Hello, world!")
            """
        reloadInputViews()
    }
}
