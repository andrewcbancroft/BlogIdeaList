//
//  BlogIdeaEditorViewController.swift
//  BlogIdeaList
//
//  Created by Andrew Bancroft on 6/7/19.
//  Copyright © 2019 Andrew Bancroft. All rights reserved.
//

import UIKit
import CoreData

class BlogIdeaEditorViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    var blogIdea: BlogIdea!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUIValues()
    }
    
    func setUIValues() {
        guard let blogIdea = self.blogIdea else { return }
        
        self.titleTextField.text = blogIdea.ideaTitle
        self.descriptionTextField.text = blogIdea.ideaDescription
    }
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.blogIdea == nil {
            self.blogIdea = (NSEntityDescription.insertNewObject(forEntityName: BlogIdea.entityName,
                                                                 into: self.managedObjectContext) as! BlogIdea)
        }
        
        self.blogIdea.ideaTitle = self.titleTextField.text
        self.blogIdea.ideaDescription = self.descriptionTextField.text
        
        do {
            try self.managedObjectContext.save()
            _ = self.navigationController?.popViewController(animated: true)
        } catch {
            let alert = UIAlertController(title: "Trouble Saving",
                                          message: "Something went wrong when trying to save the Blog Idea.  Please try again...",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: {(action: UIAlertAction) -> Void in
                                            self.managedObjectContext.rollback()
                                            self.blogIdea = NSEntityDescription.insertNewObject(forEntityName: BlogIdea.entityName, into: self.managedObjectContext) as? BlogIdea
                                            
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.managedObjectContext.rollback()
    }

}
