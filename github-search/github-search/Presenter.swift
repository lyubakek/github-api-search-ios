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
    
    private var isLoading = false
    private var searchBarText: String = ""
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
        searchBarText = text
        clean()
        delegate?.updateUI()
        loadRepositories(searshText: text, page: currentPage)
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
    private func load(_ nextPage: Int) {
        if isLoading == true {
            return
        }
        isLoading = true
        let query = searchBarText
        currentPage = nextPage
        loadRepositories(searshText: query, page: currentPage)
    }
    
    private func buildGitHubURL(searchText: String, page: Int) -> URL {
        let urlString = "https://api.github.com/search/repositories?q=\(searchText)&sort=stars&order=desc&per_page=30&page=\(page)"
        let url = URL(string: urlString)!
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
