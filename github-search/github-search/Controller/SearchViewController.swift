//
//  ViewController.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 26.12.2021.
//

import UIKit
import Foundation

class SearchViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var currentSearchTask: URLSessionTask?
    
    var repositories = [Repository]()
    var hasSearched = false
    
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
            let product = try? decoder.decode(RootSearchResult.self, from: data)
            
            DispatchQueue.main.async {
                self.repositories.append(contentsOf: product?.items ?? [])
                self.tableView.reloadData()
            }

        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
//    func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Result<ResponseType, Error>) -> Void) -> URLSessionTask {
//        let url = URL(string: "https://api.github.com/search/repositories?q=swift&sort=stars&order=desc&per_page=30&page=1")!
//
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            print(String(data: data, encoding: .utf8)!)
//        }
//
//        task.resume()
//        return task
//    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            hasSearched = true
            repositories = []

            
            parse(searshText: searchBar.text!)
            

            tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print(#function)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        print(#function)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        print(#function)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if repositories.count == 0 {
            return 1
        } else {
            return repositories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(
                style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if repositories.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = repositories[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.url
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
