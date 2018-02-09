//
//  ViewController.swift
//  NSURLSessionMaster
//
//  Created by chang on 2018/02/07.
//  Copyright © 2018年 zhang jieshuo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionTaskDelegate {
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
    //MARK:- ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.resetState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Actions
    
    @IBAction func button1Action(_ sender: UIButton) {
        self.resetState()
        self.uploadWavFile(fileName: "voice1")
    }
    
    @IBAction func button2Action(_ sender: UIButton) {
        self.resetState()
        self.uploadWavFile(fileName: "voice2")
    }
    
    @IBAction func button3Action(_ sender: UIButton) {
        self.resetState()
        self.uploadWavFile(fileName: "voice3")
    }
    
    //MARK:- Methods
    
    func uploadWavFile(fileName: String) {
        // parameterを設定して
//        let methodParameters = [
//            "api_key": appDelegate.apiKey,
//            "request_token": requestToken
//        ]
        
        // sessionを用意して
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        // requestを生成して
        let url = URL(string: "http://api.nohttp.net/upload")!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("audio/wav", forHTTPHeaderField: "Content-Type") // http request header
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = nil // http request body
        
        // fileを用意して
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "wav") else {
            fatalError("File not found")
        }
        let fileURL = URL.init(fileURLWithPath: filePath)
        
        // session、request、fileからtaskを生成して
        let task = session.uploadTask(with: request, fromFile: fileURL, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) in
            // 結果をもらって、利用して
            DispatchQueue.main.async {
                if error != nil {
                    
                    print("error : ", error.debugDescription)
                    print("HTTPリクエスト失敗")

                    self.inputStringToLog(string: "error : " + String(error.debugDescription))
                    self.inputStringToLog(string: "HTTPリクエスト失敗")
                } else {
                    
                    print("reponse : ", response.debugDescription)
                    print("HTTPリクエスト成功")
                    
                    self.inputStringToLog(string: "reponse : " + String(response.debugDescription))
                    self.inputStringToLog(string: "HTTPリクエスト成功")
                    
                    if data != nil {
                        print(data!)
                    }
                }
            }
            
        })
        
        // taskをresumeして
        task.resume()
    }
    
    func inputStringToLog(string: String) {
//        DispatchQueue.main.sync {
            if string.isEmpty {
                return
            } else {
                self.logTextView.text = self.logTextView.text + "\n"
                self.logTextView.text = self.logTextView.text + string
            }
//        }
    }
    
    func resetState() {
        self.logTextView.text = ""
        self.progressView.progress = 0.0
    }
    
    //MARK:- URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        // 通信情報をもらって
        print("redirectCount =", metrics.redirectCount)
        print("taskInterval =", metrics.taskInterval)
        print("transactionMetrics =", metrics.transactionMetrics)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // 完了済み
        if (error != nil) {
            print("HTTPリクエスト失敗")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("session \(session) uploaded \(uploadProgress * 100)%.")
        // main thread で更新する
        DispatchQueue.main.sync {
            self.progressView.progress = uploadProgress
        }
    }

}
