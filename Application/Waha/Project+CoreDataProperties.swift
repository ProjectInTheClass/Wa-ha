//
//  Project+CoreDataProperties.swift
//  Waha
//
//  Created by Teo Hwang on 2020/11/12.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//
//

import Foundation
import CoreData
import PencilKit


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
    @NSManaged public var thumbnailArray: [UIImage]?

}

extension Project : Identifiable {

}
