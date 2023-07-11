//
//  ViewController.swift
//  SytemViewController
//
//  Created by Chun-Li Cheng on 2022/4/13.
//

import UIKit
import SafariServices
import WebKit

import MessageUI

class ViewController: UIViewController {
    @IBOutlet weak var showImageView: UIImageView!
    
    private var swipeLeftGestureRecognizer: UISwipeGestureRecognizer!
    private var swipeRightGestureRecognizer: UISwipeGestureRecognizer!
    private lazy var webView = {
        // 設定在安全框內
        let webView = WKWebView(frame: view.safeAreaLayoutGuide.layoutFrame)

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeftGestureRecognizer.direction = .left
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRightGestureRecognizer.direction = .right
        
        webView.addGestureRecognizer(swipeLeftGestureRecognizer)
        webView.addGestureRecognizer(swipeRightGestureRecognizer)
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // share 也有 email 選項，可自行鍵入收件人、標題及內文
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let image = showImageView.image else { return }
        let activityController =
        UIActivityViewController(activityItems: [image],
                                 applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        present(activityController, animated: true, completion: nil)
        
        print("shareButton tapped.")
    }
    
    @IBAction func safariButtonTapped(_ sender: UIButton) {
//        if let url = URL(string: "https://apple.com") {
//            let webPage = SFSafariViewController(url: url)
//            present(webPage, animated: true, completion: nil)
//        }
        
        view.addSubview(self.webView)

        if let url = URL(string: "https://apple.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
//        if let url = URL(string: "https://apple.com") {
//            let webView = WKWebView(frame: view.bounds)
//            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            view.addSubview(webView)
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        
    }
    
    @objc private func handleSwipeLeft() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func handleSwipeRight() {
//        if webView.canGoBack {
//            webView.goBack()
//        }
        if webView.canGoBack {
            webView.goBack()
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.webView.alpha = 0.0
            }) { _ in
                self.webView.removeFromSuperview()
                self.webView.alpha = 1.0
            }
//            webView.removeFromSuperview()
            
//            if let navigationController = navigationController {
//                navigationController.popViewController(animated: true)
//            } else {
//                dismiss(animated: true, completion: nil)
//            }
        }
    }

    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Choose your image",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let cancelAct = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAct)
        
        // 設定 camera 按鈕及動作
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAct = UIAlertAction(title: "Camera",
                                          style: .default) { act in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
                
                print("take a photo")
            }
            
            alert.addAction(cameraAct)
        }
        
        // 設定 photo library 按鈕及動作
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibrary = UIAlertAction(title: "Photo Library",
                                             style: .default) { act in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
                
                print("choose a photo")
            }
            
            alert.addAction(photoLibrary)

        }

        alert.popoverPresentationController?.sourceView = sender
        present(alert, animated: true, completion: nil)
        
        print("cameraButton tapped.")
    }
    
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else {
            return print("Can't send mail.")
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
//        mail.setToRecipients(["cowton0627@iCould.com"])
        // 設定收件者、信件標題及內文
        mail.setToRecipients(["cowton0627@gmail.com"])
        mail.setSubject("Dear, this is for you")
        mail.setMessageBody("I want to share this moment to you.", isHTML: false)
        
        // 將 image 轉為 jpeg 格式
        if let image = showImageView.image,
           let jpegData = image.jpegData(compressionQuality: 0.5) {
            // 設定格式及檔案名稱
            mail.addAttachmentData(jpegData,
                                   mimeType: "image/jpeg",
                                   fileName: "photo.jpg")
        }
        
        present(mail, animated: true, completion: nil)
        
    }


}

// ImagePicker 必須 conform 這兩個 protocol 才能使用
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        showImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    // 結束編輯時離開
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

