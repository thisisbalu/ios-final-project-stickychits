//
//  CoreDataHelper.swift
//  StickyChits
//
//  Created by Bala on 28/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import Foundation

import MagicalRecord

private enum CoreDataError: Error {
    case setUpCoreData
    case saveContext
    case fetchManagedObjectsError
}

class CoreDataHelper: NSObject {
    // MARK: CoreData Service
        
        class func initializeCoreDataStack() {
            print("initializing coredata stack")
            
            MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
            MagicalRecord.setErrorHandlerTarget(self, action: #selector(CoreDataHelper.haldleCoreDataCrashes(_:)))
            MagicalRecord.setupCoreDataStack()
            NSManagedObjectContext.mr_().mergePolicy = NSOverwriteMergePolicy
            NSManagedObjectContext.mr_default().mergePolicy = NSOverwriteMergePolicy
            NSManagedObjectContext.mr_rootSaving().mergePolicy = NSOverwriteMergePolicy
        }
        
        class func deleteAllCoreDataEntities() {
            
            if let model = NSManagedObjectModel.mr_default() {
                
                for entity in model.entities {
                    
                    if let clazz = NSClassFromString(entity.managedObjectClassName) {
                        _ = clazz.mr_truncateAll()
                    }
                }
            }
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
        
        @objc class func haldleCoreDataCrashes(_ error: NSError) {
            MagicalRecord.cleanUp()
        }
}
