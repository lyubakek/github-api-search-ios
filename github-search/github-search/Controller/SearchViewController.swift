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
    func checkForLoadingNewPages(_ index: Int)
    var hasMorePages: Bool { get }
}

class SearchViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: PresenterProtocol!
    
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
            presenter.searchQueryDidChange(text: searchBar.text!)
            tableView.reloadData()
        }
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
        
        if presenter.repositories.count == 0 {
            return 1
        } else {
            return presenter.repositories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        
        if presenter.repositories.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = presenter.repositories[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.url
        }
        presenter.checkForLoadingNewPages(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: presenter.repositories[indexPath.row].url) else { return }
        UIApplication.shared.open(url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: PresenterDelegate {
    func updateUI() {
        if presenter.hasMorePages {
            tableView.tableFooterView = loadingView
        } else {
            tableView.tableFooterView = nil
        }
        tableView.reloadData()
    }
}
