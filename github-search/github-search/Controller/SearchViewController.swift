//
//  ViewController.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 26.12.2021.
//

import UIKit
import Foundation

protocol PresenterProtocol: class {
    func searchQueryDidChange(text: String)
    var repositories: [RepositoryResponse] { get }
}

class SearchViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var currentSearchTask: URLSessionTask?
    var presenter: PresenterProtocol!
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let presenter = Presenter()
        presenter.delegate = self
        self.presenter = presenter
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            hasSearched = true
            presenter.searchQueryDidChange(text: searchBar.text!)
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
        } else if presenter.repositories.count == 0 {
            return 1
        } else {
            return presenter.repositories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(
                style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if presenter.repositories.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = presenter.repositories[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.url
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: presenter.repositories[indexPath.row].url) else { return }
        UIApplication.shared.open(url)
    }
    
}

extension SearchViewController: PresenterDelegate {
    func updateUI() {
        tableView.reloadData()
    }
}
