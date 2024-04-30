//
//  IngredientsViewController.swift
//  RecipeApp
//
//  Created by Immanuel on 29/04/24.
//

import Foundation
import UIKit
import CoreData

class IngredientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct IngredientDetail {
        let ingredient: Ingredient
        let totalAmount: Double
    }
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var recipe: Recipe!
    var ingredientsDetail: [IngredientDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadIngredients()
        navigationItem.title = recipe.recipeName
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadIngredients() {
        let ingredientsFetchRequest = NSFetchRequest<Ingredient>(entityName: "Ingredient")
        
        if var fetchedAllIngredients = try? PersistenceController.shared.persistentContainer.viewContext.fetch(ingredientsFetchRequest) {
            
            // reset ingredientsDetail
            ingredientsDetail = []
            
            // filtering current recipe ingredients
            let recipeIngredients = fetchedAllIngredients.filter({ $0.recipe == recipe })
            
            for recipeIngredient in recipeIngredients {
                
                var totalAmount: Double = 0
                
                // name matching ingredients and calculating total amount
                // filtering to avoid rechecking matched ingredients
                fetchedAllIngredients = fetchedAllIngredients.filter({
                    if $0.name!.caseInsensitiveCompare(recipeIngredient.name!) == .orderedSame {
                        totalAmount += $0.amount
                        return false
                    }
                    return true
                })
                
                ingredientsDetail.append(
                    IngredientDetail(
                        ingredient: recipeIngredient,
                        totalAmount: totalAmount
                    )
                )
            }
            
        }
    }
    
    @IBAction func tappedAddIngredient() {
        if let ingredientName = name.text,
           !ingredientName.isEmpty,
           let amountText = amount.text,
           let amountDoubleValue = Double(amountText) {
            let ingredient = Ingredient(context: PersistenceController.shared.persistentContainer.viewContext)
            ingredient.name = ingredientName
            ingredient.amount = amountDoubleValue
            ingredient.recipe = recipe
            PersistenceController.shared.saveContext()
            loadIngredients()
            tableView.reloadData()
            name.text = ""
            amount.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ingredientsDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        var content = cell.defaultContentConfiguration()
        let ingredientDetail = ingredientsDetail[indexPath.row]
        if ingredientDetail.totalAmount > ingredientDetail.ingredient.amount {
            let attributedText = NSMutableAttributedString(string: "Name: \(ingredientDetail.ingredient.name!), Amount: \(ingredientDetail.ingredient.amount)")
            let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .bold)]
            let totalAmount = NSAttributedString(string: ", Total Amount: \(ingredientDetail.totalAmount)", attributes: boldAttributes)
            attributedText.append(totalAmount)
            content.attributedText = attributedText
        } else {
            content.text = "Name: \(ingredientDetail.ingredient.name!), Amount: \(ingredientDetail.ingredient.amount)"
        }
        cell.contentConfiguration = content
        return cell
    }
    
}
