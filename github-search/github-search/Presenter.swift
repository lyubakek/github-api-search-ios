//
//  Presenter.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 28.12.2021.
//

import Foundation

protocol PresenterDelegate: class {
    func updateUI()
    func reloadAndScroll()
}

class Presenter: PresenterProtocol {
    
    weak var delegate: PresenterDelegate?
    var repositories = [RepositoryResponse]()
    
    var isLoading = false
    var totalCount = 0
    var currentPage = 1
    var hasMorePages: Bool {
        return repositories.count < totalCount
    }
    var nextPage: Int {
        return hasMorePages ? currentPage + 1 : currentPage
    }
    var searchBarText: String = ""
    
    func searchQueryDidChange(text: String) {
        searchBarText = text
        parse(searshText: text, page: currentPage)
    }
    
    func checkForLoadingNewPages(_ index: Int) {
        if hasMorePages, index == repositories.count - 1 {
            load(nextPage)
        }
    }
    func restore(repositories: [RepositoryResponse], currentPage: Int, totalCount: Int) {
        self.repositories = repositories
        self.currentPage = currentPage
        self.totalCount = totalCount
        delegate?.reloadAndScroll()
    }
    func load(_ nextPage: Int) {
        if isLoading == true {
            return
        }
        isLoading = true
        let query = searchBarText
        currentPage = nextPage
        parse(searshText: query, page: currentPage)
    }
    
    func buildGitHubURL(searchText: String, page: Int) -> URL {
        let urlString = String(
            format: "https://api.github.com/search/repositories?q=\(searchText)&sort=stars&order=desc&per_page=30&page=\(page)")
        print(urlString)
        let url = URL(string: urlString)
        return url!
    }
    
    func parse(searshText: String, page: Int) { // completion:  @escaping (Result<String, Error>) -> Void
        let url = buildGitHubURL(searchText: searshText, page: page)
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = ["accept":"application/vnd.github.v3+json"]
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            let product = try? decoder.decode(RootSearchResponse.self, from: data)
            DispatchQueue.main.async {
                self.totalCount = product?.totalCount ?? 0
                self.repositories.append(contentsOf: product?.items ?? [])
                self.delegate?.updateUI()
                self.isLoading = false
            }
        }
        task.resume()
    }
}
