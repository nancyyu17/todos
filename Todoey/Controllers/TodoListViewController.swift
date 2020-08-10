//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var todosItem = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return todosItem.count
    }
    
    // to show the list of todos in the TodoLists Scene
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for:indexPath)
        
        let currentItem = todosItem[indexPath.row]
        cell.textLabel?.text = currentItem.title
        cell.accessoryType = currentItem.done ?.checkmark: .none

        return cell
    }
    
    
    // delegate - select a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // unselect + select: none and checkmark
        todosItem[indexPath.row].done = !todosItem[indexPath.row].done
        
//        context.delete(todosItem[indexPath.row])
//        todosItem.remove(at:indexPath.row)
        
        // save to database
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Add new todos
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            // append the added item to the todosItem array
            self.todosItem.append(newItem)
            
            // storing updated info to a customized plist
            self.saveItems()
            
        }
        alert.addTextField { (alertText) in
            alertText.placeholder = "Create new item"
            textField = alertText
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    
    }
    
    
    // save data to database
    func saveItems() {
        do {
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // load data from database
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()){
        do{
            todosItem = try context.fetch(request)
        }catch{
            print("Error at fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    

}

// MARK: -Search Bar
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        // search for the item typed in search bar
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(with: request)
    }
}

