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
import RealmSwift

class ViewController: UIViewController {
  
  let queue = DispatchQueue.global(qos: .utility)
  
  var pagesCount: Int = 0
  
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let path = try! Realm().configuration.fileURL?.absoluteString
    print(path!)
    
    loadPage()
    
    //    let pages = try! Realm().objects(PageData.self)
    //
    //    for page in pages! {
    //      print("Title: \(page.title)")
    //      print("Link: \(page.link)")
    //      print("Image: \(page.image)\n")
    //    }
    
    print(pagesCount)
  }
  
  private func loadPage() {
    
    let baseUrl = "https://vesti.ua"
    let basePath = "/feed/1-vse-novosti/"
    
    let semaphore = DispatchSemaphore(value: 0)
    let realm = try! Realm()
    
    var pageNumber = 1
    var url: String
    
    while pageNumber != pagesCount {
      url = "\(baseUrl)\(basePath)\(pageNumber)"
      AF.request(url).validate().responseString(queue: queue) { response in
        
        switch response.result {
        case .success(let html):
          
          do {
            let doc: Document = try SwiftSoup.parse(html)
            let main: Element = try doc.getElementsByClass("main").first()!
            
            let articles: Elements = try main.getElementsByClass("col-12 imageArticleRedesignTop").select("a")
            
            if self.pagesCount == 0 {
              
              DispatchQueue.main.async {
                self.webView.loadHTMLString(html, baseURL: URL(string: "\(baseUrl)\(basePath)"))
              }
              
              let pagination: Elements = try main.getElementsByClass("pages").select("a")
              self.pagesCount = Int(try pagination.array().last!.attr("href").dropFirst(basePath.count))!
            }
            
            for page in articles.array() {
              
              let pageData = PageData()
              
              pageData.link = baseUrl + (try page.attr("href"))
              pageData.image = baseUrl + (try page.select("img").attr("data-src"))
              pageData.title = try page.select("img").attr("alt")
              
              DispatchQueue.main.async {
                do {
                  try realm.write {
                    realm.add(pageData, update: .modified)
                  }
                } catch let error {
                  print(error.localizedDescription)
                }
              }
            }
          } catch let error {
            print(error.localizedDescription)
          }
        case .failure(let error):
          print(error.localizedDescription)
        }
        print(url)
        pageNumber += 1
        semaphore.signal()
      }
      semaphore.wait()
    }
  }
  
}

