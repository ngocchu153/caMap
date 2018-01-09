//
//  CategoriesVC.swift
//  caMap
//
//  Created by ngoChu on 12/22/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import UIKit

protocol GetCategoryDelegate {
    func updatePlacesOnMap(category: String)
}

class CategoriesVC: UITableViewController {
    var delegate: GetCategoryDelegate?
    
    var selectedCategory: String!
    
    var list:[Category] = ["University", "Food", "Doctor", "School", "Hair_care", "Restaurant", "Pharmacy", "Atm", "Gym", "Store"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CATEGORY_CELL", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as UITableViewCell!
        selectedCategory = (selectedCell?.textLabel?.text)!
        print(selectedCategory)
        delegate?.updatePlacesOnMap(category: selectedCategory)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
}

