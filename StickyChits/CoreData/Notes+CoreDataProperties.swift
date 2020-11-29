//
//  Notes+CoreDataProperties.swift
//  StickyChits
//
//  Created by Bala on 28/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var active: Bool
    @NSManaged public var createdBy: String
    @NSManaged public var createdTime: Int64
    @NSManaged public var details: String
    @NSManaged public var key: String
    @NSManaged public var title: String
    @NSManaged public var folderID: String
    @NSManaged public var updatedTime: Int64

}
