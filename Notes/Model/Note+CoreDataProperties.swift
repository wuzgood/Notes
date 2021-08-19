//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Wuz Good on 19.08.2021.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var body: String?

}

extension Note : Identifiable {

}
