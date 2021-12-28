//
//  Presenter.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 28.12.2021.
//

import Foundation

protocol PresenterDelegate: class {
    func updateUI()
}

class Presenter: PresenterProtocol {
    weak var delegate: PresenterDelegate?
    
    private(set) var repositories = [RepositoryResponse]()

    
    func searchQueryDidChange(text: String) {
        parse(searshText: text)
    }
    
    func gitAPIURL(searchText: String) -> URL {
        let urlString = String(
            format: "https://api.github.com/search/repositories?q=\(searchText)&sort=stars&order=desc&per_page=30&page=1")
        print(urlString)
        let url = URL(string: urlString)
        return url!
    }
    
    func parse(searshText: String) {
        let url = gitAPIURL(searchText: searshText)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = ["accept":"application/vnd.github.v3+json"]
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            let product = try? decoder.decode(RootSearchResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.repositories.append(contentsOf: product?.items ?? [])
                self.delegate?.updateUI()
                
            }
        }
        task.resume()
    }
}
