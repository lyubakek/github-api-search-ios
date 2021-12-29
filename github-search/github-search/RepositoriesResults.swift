//
//  RepositoriesResults.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 29.12.2021.
//

import Foundation

struct RepositoriesResult {
  let repository: [RepositoryResponse]?
  let error: Error?
  let currentPage: Int
  let pageCount: Int
  
  var hasMorePages: Bool {
    return currentPage < pageCount
  }
  
  var nextPage: Int {
    return hasMorePages ? currentPage + 1 : currentPage
  }
}
