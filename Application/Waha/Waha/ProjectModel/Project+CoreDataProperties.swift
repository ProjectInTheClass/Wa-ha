//
//  Project+CoreDataProperties.swift
//  
//
//  Created by USER on 2020/11/08.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var frameRate: Int64
    @NSManaged public var projectName: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var videoURL: String?

}
