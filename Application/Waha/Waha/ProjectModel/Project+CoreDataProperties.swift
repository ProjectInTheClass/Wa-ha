//
//  Project+CoreDataProperties.swift
//  
//
//  Created by Teo Hwang on 2020/11/12.
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
    @NSManaged public var drawingData: [PKDrawing]?
    @NSManaged public var videoData: [UIImage]?

}
