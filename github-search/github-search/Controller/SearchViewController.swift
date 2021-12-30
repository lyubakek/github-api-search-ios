//
//  ViewController.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 26.12.2021.
//

import UIKit
import Foundation

protocol PresenterProtocol: class {
    var searchText: String { get }
    var repositories: [RepositoryResponse] { get set }
    var hasMorePages: Bool { get }
    var totalCount: Int { get }
    var currentPage: Int { get }
    func searchQueryDidChange(text: String)
    func checkForLoadingNewPages(_ index: Int)
    func restore(text: String, repositories: [RepositoryResponse], currentPage: Int, totalCount: Int)
    
}

struct RestorationState: Codable {
    let text: String
    let response: [RepositoryResponse]
    let currentPage: Int
    let contentOffset: CGFloat
    let totalCount: Int
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: PresenterProtocol!
    var restorationState: RestorationState?
    private var contentOffset: CGFloat = 0.0
    private var generatedRestorationData: Data? {
        guard presenter.repositories.count > 0,
              let data = try? JSONEncoder().encode(RestorationState(text: presenter.searchText,response: presenter.repositories, currentPage: presenter.currentPage, contentOffset: contentOffset, totalCount: presenter.totalCount)) else { return nil }
        return data
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let presenter = Presenter()
        presenter.delegate = self
        self.presenter = presenter
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userActivity = view.window?.windowScene?.userActivity
        if let restorationState = restorationState {
            presenter.restore(text: restorationState.text, repositories: restorationState.response, currentPage: restorationState.currentPage, totalCount: restorationState.totalCount)
            contentOffset = restorationState.contentOffset
            self.restorationState = nil
        }
    }
    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
        if let generatedRestorationData = generatedRestorationData {
            activity.addUserInfoEntries(from: [Constants.restorationKey: generatedRestorationData])
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchBar.resignFirstResponder()
            presenter.searchQueryDidChange(text: text)
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
            cell.textLabel?.text = "(Nothing found)"
            cell.detailTextLabel?.text = ""
        } else {
            let searchResult = presenter.repositories[indexPath.row]
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = searchResult.url
            if presenter.repositories[indexPath.row].state {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        presenter.checkForLoadingNewPages(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: presenter.repositories[indexPath.row].url) else { return }
        UIApplication.shared.open(url)
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        presenter.repositories[indexPath.row].state = true
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentOffset = scrollView.contentOffset.y
        }
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
    func restoreView() {
        tableView.reloadData()
        searchBar.text = presenter.searchText
        DispatchQueue.main.async {
            self.tableView.setContentOffset(CGPoint(x: 0.0, y: self.contentOffset), animated: true)
        }
    }
}
