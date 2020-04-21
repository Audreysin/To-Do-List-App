//
//  CategoryViewController.swift
//  To-Do List
//
//  Created by Audrey Sin Fai Lam on 2020-03-31.
//  Copyright © 2020 Audrey Sin Fai Lam. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    var categoryArray : [Category] = []
        
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadList()
        tableView.rowHeight = 80.0
    }
    
    //MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            if textField.text! != "" {
                
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text
                self.categoryArray.append(newCategory)
                
                self.saveList()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Datasource Methods
    
    // Sets up the number of rows required
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // Ask the datasource to insert a cell at a particular location on the TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell//Reusable cell
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        cell.delegate = self
        
        return cell
        
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    //MARK: - Data Manipulation Methods
    
    func saveList() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadList(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
                
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    // This function runs just before we performSegue is called
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      //  if segue.identifier == "goToItem"
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
}

// MARK: - Swipe Cell Delegate Method
extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.categoryArray[indexPath.row])
            do {
                try self.context.save()
            } catch {
                print("Error: \(error)")
            }
            self.categoryArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")

        return [deleteAction]
    }
    
}
