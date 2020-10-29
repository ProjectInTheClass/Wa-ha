//
//  Project+CoreDataProperties.swift
//  201012_Waha_ProjectList_v001
//
//  Created by Teo Hwang on 2020/10/15.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var projectName: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var frameRate: Int64

}

extension Project : Identifiable {

}
