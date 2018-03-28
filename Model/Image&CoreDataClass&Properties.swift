//
//  Image&CoreDataClass&Properties.swift
//  Virtual Tourist
//
//  Created by Jaskirat Singh on 17/03/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import Foundation
import CoreData

//MARK: Image & CoreData Class

public class Images: NSManagedObject
{
}

// -----------------------------------------------------------------------------------

//MARK: Image & CoreData Properties

extension Images
{
    @nonobjc public class func fetchRequest()-> NSFetchRequest<Images>
    {
        return NSFetchRequest<Images>(entityName: "Images")
    }
    
    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?
    
    convenience init(image: NSData?, point: Pin, context: NSManagedObjectContext)
    {
        if let entity = NSEntityDescription.entity(forEntityName: "Images", in: context)
        {
            self.init(entity: entity, insertInto: context)
            self.image = image
            self.pin = point
        }
        else
        {
            fatalError("ERROR: Unable to find Entity")
        }
    }
}
