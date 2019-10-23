//
//  PageData.swift
//  SwiftHtmlParsing
//
//  Created by Victor Smirnov on 22.10.2019.
//  Copyright © 2019 Victor Smirnov. All rights reserved.
//

import Foundation
import RealmSwift

class PageData: Object {
  
  @objc dynamic var title: String = ""
  @objc dynamic var link: String = ""
  @objc dynamic var image: String = ""
  
  override static func primaryKey() -> String? {
    return "title"
  }
}
