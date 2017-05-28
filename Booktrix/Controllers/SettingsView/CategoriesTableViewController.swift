//
//  CategoriesTableViewController.swift
//  Booktrix
//
//  Created by Impresyjna on 26.05.2017.
//  Copyright © 2017 Impresyjna. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    let viewModel = CategoriesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString.title
        
        tableView.registerNib(for: CategoryCell.self)
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchCategories()
    }
    
    func fetchCategories() {
        showHud()
        viewModel.categoriesIndex(completion: { [weak self] result in
            switch result {
            case .success:
                self?.tableView.reloadData()
                self?.hideHud()
            case .failure(let error):
                self?.showError(title: nil, subtitle: error.errorMessage, dismissDelay: 3.0)
            }
        })
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count \(viewModel.categoriesList.count)")
        return viewModel.categoriesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = viewModel.categoriesList[indexPath.row]
        
        let cell: CategoryCell = tableView.dequeue()
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

fileprivate extension LocalizedString {
    static let title = NSLocalizedString("booktrix.categories.title", comment: "Categories")
}
