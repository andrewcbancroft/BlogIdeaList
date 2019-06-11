//
//  ViewController.swift
//  BlogIdeaList
//
//  Created by Andrew Bancroft on 6/7/19.
//  Copyright © 2019 Andrew Bancroft. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<BlogIdea>!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        configureFetchedResultsController()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
            
        }
    }
    
    // MARK: Fetched Results Controller Configuration
    func configureFetchedResultsController() {
        let blogIdeasFetchRequest = NSFetchRequest<BlogIdea>(entityName: "BlogIdea")
        let primarySortDescriptor = NSSortDescriptor(key: "ideaTitle", ascending: true)
        blogIdeasFetchRequest.sortDescriptors = [primarySortDescriptor]

        self.fetchedResultsController = NSFetchedResultsController<BlogIdea>(
            fetchRequest: blogIdeasFetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        self.fetchedResultsController.delegate = self

    }
    
    
    // MARK: TableView Data Source
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let blogIdea = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = blogIdea.ideaTitle
        cell.detailTextLabel?.text = blogIdea.ideaDescription
        
        return cell
    }
    
    // MARK: TableView Delegate
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let blogIdea = fetchedResultsController.object(at: indexPath)
            confirmDeleteForBlogIdea(blogIdea)
        }
    }
    
    // MARK: Delete Confirmation and Handling
    var blogIdeaToDelete: BlogIdea?
    
    func confirmDeleteForBlogIdea(_ blogIdea: BlogIdea) {
        
        self.blogIdeaToDelete = blogIdea
        
        let alertController = UIAlertController(title: "Delete Blog Idea",
                                                message: "Are you sure you want to delete this Blog Idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            self.managedObjectContext.delete(self.blogIdeaToDelete!)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                self.managedObjectContext.rollback()
                print("Something went wrong: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: NSFetchedResultsController Delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRow(at: updateIndexPath)
                let updatedBlogIdea = self.fetchedResultsController.object(at: updateIndexPath)
                
                cell?.textLabel?.text = updatedBlogIdea.ideaTitle
                cell?.detailTextLabel?.text = updatedBlogIdea.ideaDescription
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = NSIndexSet(index: sectionIndex) as IndexSet
        
        switch type {
        case .insert:
            self.tableView.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(sectionIndexSet, with: .fade)
        default:
            break
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        guard let editorVC = segue.destination as? BlogIdeaEditorViewController else { return }
        editorVC.managedObjectContext = self.managedObjectContext

        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            let selectedBlogIdea = self.fetchedResultsController.object(at: selectedIndexPath)
            editorVC.blogIdea = selectedBlogIdea
        }
     }
}

