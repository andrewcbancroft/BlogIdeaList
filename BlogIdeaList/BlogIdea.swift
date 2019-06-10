//
//  BlogIdea+CoreDataProperties.swift
//  BlogIdeaList
//
//  Created by Andrew Bancroft on 6/7/19.
//  Copyright © 2019 Andrew Bancroft. All rights reserved.
//
//

import Foundation
import CoreData


public class BlogIdea: NSManagedObject {

    @NSManaged public var ideaTitle: String?
    @NSManaged public var ideaDescription: String?

    static var entityName: String { return "BlogIdea" }
}
