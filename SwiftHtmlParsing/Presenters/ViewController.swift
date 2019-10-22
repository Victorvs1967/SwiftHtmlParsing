//
//  ViewController.swift
//  SwiftHtmlParsing
//
//  Created by Victor Smirnov on 21.10.2019.
//  Copyright © 2019 Victor Smirnov. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftSoup

class ViewController: UIViewController {
  
  var pagesCount: Int = 0
  var pages = [String: (String, String)]()
  
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadPage()
    print(pagesCount)
    
    for page in pages {
      print("Title: \(page.key)")
      print("Link: \(page.value.0)")
      print("Image: \(page.value.1)\n")
    }
  }
  
  private func loadPage() {
    
    let baseUrl = "https://vesti.ua"
    let basePath = "/feed/1-vse-novosti/"
    
    let queue = DispatchQueue.global(qos: .utility)
    let semaphore = DispatchSemaphore(value: 0)
    
    var page = 1
    
//    while page != pagesCount {
    while page < 250 {
      print(page, pagesCount)
      AF.request(baseUrl + basePath).validate().responseString(queue: queue) { response in
        
        switch response.result {
        case .success(let html):
          
          //        DispatchQueue.main.async {
          //          self.webView.loadHTMLString(html, baseURL: URL(string: url))
          //        }
          
          do {
            let doc: Document = try SwiftSoup.parse(html)
            let main: Element = try doc.getElementsByClass("main").first()!
            
            let articles: Elements = try main.getElementsByClass("col-12 imageArticleRedesignTop").select("a")
            
            if self.pagesCount == 0 {
              let pagination: Elements = try main.getElementsByClass("pages").select("a")
              self.pagesCount = Int(try pagination.array().last!.attr("href").dropFirst(basePath.count))!
            }
            
            for page in articles.array() {
              let link = try page.attr("href")
              let img = try page.select("img").attr("data-src")
              let title = try page.select("img").attr("alt")
              
              self.pages[title] = (baseUrl + link, baseUrl + img)
            }
          } catch let error {
            print(error.localizedDescription)
          }
        case .failure(let error):
          print(error.localizedDescription)
        }
        page += 1
        print(self.pagesCount)
        semaphore.signal()
      }
      semaphore.wait()
    }
  }
  
}

