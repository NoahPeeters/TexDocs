//
//  CreateFileCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createCreateFileCommit() -> CreateFileCommit {
        let commit = NSEntityDescription.insertNewObject(forEntityName: "CreateFileCommit", into: self) as! CreateFileCommit
        return commit
    }
}
