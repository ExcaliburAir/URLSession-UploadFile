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
        self.uploadJPGfile()
    }
    
    @IBAction func button3Action(_ sender: UIButton) {
        self.resetState()
        self.uploadWAVfile()
    }
    
    //MARK:- Methods
    
    func uploadWavFile(fileName: String) {
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
    
    // 上传成功
    func uploadWAVfile() {
        guard let filePath = Bundle.main.path(forResource: "voice2", ofType: "wav") else {
            fatalError("File not found")
        }
        let fileURL = URL.init(fileURLWithPath: filePath)
        let data = try! Data(contentsOf: fileURL)
        
        let url = NSURL(string: "http://api.nohttp.net/upload")
        let request : NSMutableURLRequest = NSMutableURLRequest()
        
        if let u = url {
            request.url = u as URL
            request.httpMethod = "POST"
            request.timeoutInterval = 30.0
        }
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let body: NSMutableData = NSMutableData()
        var postData :String = String()
        
        let boundary:String = "---------------------------\(uniqueId)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        postData += "--\(boundary)\r\n"
        postData += "Content-Disposition: form-data; name=\"UUID\"\r\n"
        postData += "\r\n\(UUID().uuidString)\r\n"
        postData += "--\(boundary)\r\n"
        
        let filename = "Test Voice"
        postData += "Content-Disposition: form-data; name=\"wav\"; filename=\(filename)\r\n"
        postData += "Content-Type: audio/wav\r\n\r\n"
        body.append(postData.data(using: String.Encoding.utf8)!)
        body.append(data as Data)
        
        postData = String()
        postData += "\r\n"
        postData += "\r\n--\(boundary)--\r\n"
        body.append(postData.data(using: String.Encoding.utf8)!)
        request.httpBody = NSData(data:body as Data) as Data
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                //上传完毕后
                if error != nil{
                    print("error : ", error.debugDescription)
                    print("HTTPリクエスト失敗")
                    self.inputStringToLog(string: "error : " + String(error.debugDescription))
                    self.inputStringToLog(string: "HTTPリクエスト失敗")
                    
                }else{
                    print("reponse : ", response.debugDescription)
                    self.inputStringToLog(string: "reponse : " + String(response.debugDescription))
                    
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print("アプロード完了：\(String(describing: str))")
                }
            }
        })
        task.resume()
    }
    
    // 成功してます
    func uploadJPGfile() {
        // 拿到文件
        guard let filePath = Bundle.main.path(forResource: "1", ofType: "jpg") else {
            fatalError("File not found")
        }
        let fileURL = URL.init(fileURLWithPath: filePath)
        let data = try! Data(contentsOf: fileURL)
        
        // 制作请求
        let request : NSMutableURLRequest = NSMutableURLRequest()
        let url = NSURL(string: "http://api.nohttp.net/upload")
        if let u = url {
            request.url = u as URL
            request.httpMethod = "POST"
            request.timeoutInterval = 30.0
        }
        
        // 请求头
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        var postData :String = String()
        let boundary:String = "---------------------------\(uniqueId)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        postData += "--\(boundary)\r\n"
        postData += "Content-Disposition: form-data; name=\"text\"\r\n"
        let nameStr = "1122"
        postData += "\r\n\(nameStr)\r\n"
        postData += "--\(boundary)\r\n"
        postData += "Content-Disposition: form-data; name=\"image\"; filename=\"name\"\r\n"
        postData += "Content-Type: image/jpg\r\n\r\n"
        postData = String()
        postData += "\r\n"
        postData += "\r\n--\(boundary)--\r\n"
        
        // 请求文件
        let body: NSMutableData = NSMutableData()
        body.append(postData.data(using: String.Encoding.utf8)!)
        body.append(data as Data)
        body.append(postData.data(using: String.Encoding.utf8)!)
        request.httpBody = NSData(data:body as Data) as Data
        
        // 执行请求
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if error != nil{
                    print("error : ", error.debugDescription)
                    print("HTTPリクエスト失敗")
                    self.inputStringToLog(string: "error : " + String(error.debugDescription))
                    self.inputStringToLog(string: "HTTPリクエスト失敗")
                    
                }else{
                    print("reponse : ", response.debugDescription)
                    self.inputStringToLog(string: "reponse : " + String(response.debugDescription))
                    
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print("上传完毕：\(String(describing: str))")
                }
            }
        })
        task.resume()
    }
    
    // MARK:- 汪晶晶不爱我
    
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

