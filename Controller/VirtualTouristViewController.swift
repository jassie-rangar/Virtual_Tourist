//
//  VirtualTouristViewController.swift
//  Virtual Tourist
//
//  Created by Jaskirat Singh on 12/03/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import UIKit
import CoreData
import MapKit

// MARK: - Setting up delegate

let delegate = UIApplication.shared.delegate as! AppDelegate

class VirtualTouristViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate
{
    
    // MARK: - Outlets & Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    let stack = delegate.stack
    
    var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        self.firstSetup()
        self.loadData()

    }
    
    @objc func addpin(_ gest: UILongPressGestureRecognizer)
    {
        if gest.state == UIGestureRecognizerState.began
        {
            let loc = gest.location(in: mapView)
            let coord = mapView.convert(loc, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            let pin = Pin(lat: coord.latitude,long: coord.longitude, context: (fetchedResultController?.managedObjectContext)!)
            try! stack.saveContext()
            loadData()
        }
    }
    
    public func mapView(_ mapview: MKMapView, didSelect view: MKAnnotationView)
    {
        var point: NSManagedObject!
        let firstPredicate = NSPredicate(format: "latitude = %@", argumentArray: [(view.annotation?.coordinate.latitude)!])
        let secondPredicate = NSPredicate(format: "longitude = %@", argumentArray: [(view.annotation?.coordinate.longitude)!])
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let combinedPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate, secondPredicate])
        fetchRequest.predicate = combinedPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchCompletion(fetchResultController: fetchedResultController, completion: {
            let objc = fetchedResultController?.fetchedObjects as! [NSManagedObject]
            point = objc[0]
        })
        mapview.deselectAnnotation(view.annotation, animated: false)
        performSegue(withIdentifier: "push", sender: point)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let target = segue.destination as! FlickrViewController
        target.point = sender as! Pin
    }

}

extension VirtualTouristViewController
{
    func firstSetup()
    {
        mapView.delegate = self
        let gest = UILongPressGestureRecognizer(target: self, action: #selector(addpin(_: )))
        gest.delegate = self
        gest.minimumPressDuration = 0.5
        gest.allowableMovement = 1
        mapView.addGestureRecognizer(gest)
    }
    
    func loadData()
    {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false), NSSortDescriptor(key: "longitude", ascending: false)]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context  , sectionNameKeyPath: nil, cacheName: nil)
        fetchCompletion(fetchResultController: fetchedResultController, completion: {
            let pin:[Pin] = fetchedResultController?.fetchedObjects as! [Pin]
            DispatchQueue.global(qos: .userInitiated).async
            {
                var annot = [MKPointAnnotation]()
                for ann in pin
                {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: ann.latitude, longitude: ann.longitude)
                    annot.append(annotation)
                }
                DispatchQueue.main.async
                {
                    self.mapView.addAnnotations(annot)
                }
            }
        })
        
    }
    
    func fetchCompletion(fetchResultController: NSFetchedResultsController<NSFetchRequestResult>?, completion: ()->())
    {
        fetchResultController?.delegate = self as? NSFetchedResultsControllerDelegate
        startSearch()
        completion()
    }
    
    func startSearch()
    {
        if let fetchResult = fetchedResultController
        {
            do
            {
                try fetchResult.performFetch()
            }
            catch let error as NSError
            {
                print("Error occured while performing search: \n\(error)\n\(String(describing: fetchedResultController))")
            }
        }
    }

}
