//
//  Folder+CoreDataProperties.swift
//  StickyChits
//
//  Created by Bala on 28/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var active: Bool
    @NSManaged public var createdTime: Int64
    @NSManaged public var key: String
    @NSManaged public var name: String
    @NSManaged public var notesIds: String
    @NSManaged public var updatedTime: Int64

}
