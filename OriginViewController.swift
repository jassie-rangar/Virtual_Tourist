//
//  OriginViewController.swift
//  Virtual Tourist
//
//  Created by Jaskirat Singh on 26/03/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import UIKit
import CoreData

class OriginViewController: UIViewController
{
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    func fetchCompletion(fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>?, completion: ()->() )
    {
        fetchedResultController?.delegate = self as? NSFetchedResultsControllerDelegate
        startSearch()
        completion()
    }

}

extension OriginViewController
{
    func startSearch()
    {
        if let fetchController = fetchedResultsController
        {
            do
            {
                try fetchController.performFetch()
            }
            catch let error as NSError
            {
                print("ERROR: Unable to perform search operation!\n\(error)")
            }
        }
    }
}
