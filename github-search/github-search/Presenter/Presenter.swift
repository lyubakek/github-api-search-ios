//
//  Presenter.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 28.12.2021.
//

import Foundation

protocol PresenterDelegate: class {
    func updateUI()
    func restoreView()
}

class Presenter: PresenterProtocol {
    
    weak var delegate: PresenterDelegate?
    var repositories = [RepositoryResponse]()
    
    private var isLoading = false
    private(set) var searchText: String = ""
    private var task: URLSessionDataTask?
    private(set) var totalCount = 0
    private(set) var currentPage = 1
    var hasMorePages: Bool {
        return repositories.count < totalCount
    }
    var nextPage: Int {
        return hasMorePages ? currentPage + 1 : currentPage
    }
    
    func searchQueryDidChange(text: String) {
        searchText = text
        clean()
        delegate?.updateUI()
        loadRepositories(searshText: text, page: currentPage)
    }
    
    func checkForLoadingNewPages(_ index: Int) {
        if hasMorePages, index == repositories.count - 1 {
            load(nextPage)
        }
    }
    func restore(text: String, repositories: [RepositoryResponse], currentPage: Int, totalCount: Int) {
        self.repositories = repositories
        self.currentPage = currentPage
        self.totalCount = totalCount
        self.searchText = text
        delegate?.restoreView()
    }
    private func load(_ nextPage: Int) {
        if isLoading == true {
            return
        }
        isLoading = true
        let query = searchText
        currentPage = nextPage
        loadRepositories(searshText: query, page: currentPage)
    }
    
    private func buildGitHubURL(searchText: String, page: Int) -> URL {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [URLQueryItem(name: "q", value: searchText),
                                 URLQueryItem(name: "sort", value: "stars"),
                                 URLQueryItem(name: "order", value: "desc"),
                                 URLQueryItem(name: "per_page", value: "30"),
                                 URLQueryItem(name: "page", value: String(page))]
        
        let url = components.url!
        return url
    }
    
    private func loadRepositories(searshText: String, page: Int) { 
        let url = buildGitHubURL(searchText: searshText, page: page)
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = ["accept":"application/vnd.github.v3+json"]
        task = URLSession.shared.dataTask(with: urlRequest) {(data, _, _) in
            guard let data = data, let decodedResponse = try? JSONDecoder().decode(RootSearchResponse.self, from: data) else { return }
            DispatchQueue.main.async {
                self.totalCount = decodedResponse.totalCount
                self.repositories.append(contentsOf: decodedResponse.items)
                self.delegate?.updateUI()
                self.isLoading = false
            }
        }
        task?.resume()
    }
    private func clean() {
        totalCount = 0
        currentPage = 1
        repositories = []
        task?.cancel()
        task = nil
        isLoading = false
    }
}
