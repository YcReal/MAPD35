//
//  Note+CoreDataProperties.swift
//  NoteApp
//
//  Created by Yancheng Lin on 2021/6/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var noteID: String?
    @NSManaged public var text: String?

}

extension Note : Identifiable {

}
