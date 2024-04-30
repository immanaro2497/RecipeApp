//
//  RecipeViewController.swift
//  RecipeApp
//
//  Created by Immanuel on 29/04/24.
//

import UIKit
import CoreData

class RecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var recipes: [Recipe] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadRecipes()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadRecipes() {
        let recipesFetchRequest = NSFetchRequest<Recipe>(entityName: "Recipe")
        if let fetchedRecipes = try? PersistenceController.shared.persistentContainer.viewContext.fetch(recipesFetchRequest) {
            recipes = fetchedRecipes
        }
    }
    
    @IBAction func tappedAddRecipeButton() {
        if let recipeName = textField.text, !recipeName.isEmpty {
            let recipe = Recipe(context: PersistenceController.shared.persistentContainer.viewContext)
            recipe.recipeName = recipeName
            PersistenceController.shared.saveContext()
            loadRecipes()
            tableView.reloadData()
            textField.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        var content = cell.defaultContentConfiguration()
        content.text = recipes[indexPath.row].recipeName
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = UIStoryboard(name: "IngredientsView", bundle: nil).instantiateViewController(identifier: "IngredientsViewId") as? IngredientsViewController {
            controller.recipe = recipes[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}

#Preview(traits: .portrait, body: {
    RecipeViewController()
})

