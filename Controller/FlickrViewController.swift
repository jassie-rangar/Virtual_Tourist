//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Jaskirat Singh on 07/03/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrViewController: CoreDataViewController, MKMapViewDelegate, UICollectionViewDataSource
{
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionButton: UIButton!
    
    // MARK: Properties
    
    var annotation = [MKPointAnnotation]()
    var point: Pin!
    
    // MARK: IBActions
    
    @IBAction func collection(_ sender: Any)
    {
        collectionButton.isEnabled = false
        let pic = (self.point.image!) as NSSet
        for object in pic
        {
            self.fetchedResultController?.managedObjectContext.delete(object as! NSManagedObject)
        }
        obtainUrls(){ (obtained, error) in
            DispatchQueue.main.async
            {
                self.collectionButton.isEnabled = true
            }
            if obtained == false
            {
                DispatchQueue.main.async
                {
                    self.alertError(error: error!)
                }
            }
            try! self.delegate.stack.saveContext()
        }
    }
    
    func setup()
    {
        mapView.isUserInteractionEnabled = true
        self.collectionButton.isEnabled = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let coordinate2D  = CLLocationCoordinate2D(latitude: (self.point?.latitude)!, longitude: (self.point?.longitude)!)
        let annot = MKPointAnnotation()
        annot.coordinate = coordinate2D
        mapView.addAnnotations([annot])
        mapView.isScrollEnabled = false
        let span = MKCoordinateSpanMake(2.5, 2.5)
        let region = MKCoordinateRegionMake(coordinate2D, span)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        let fetchRequest = NSFetchRequest<Images>(entityName: "Images")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
        let predic = NSPredicate(format: "pin = %@", argumentArray: [self.point])
        fetchRequest.predicate = predic
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (delegate.stack.context), sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultController?.delegate = self
        self.startSearch()
        if(point.image?.count)! < 1
        {
            self.obtainUrls(){ (obtained, error) in
                DispatchQueue.main.async
                {
                    self.collectionButton.isEnabled = true
                }
                if (obtained == false)
                {
                    DispatchQueue.main.async
                    {
                        self.alertError(error: error!)
                    }
                }
                try! self.delegate.stack.saveContext()
            }
        }
        else
        {
            self.collectionButton.isEnabled = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pic", for: indexPath) as! CollectionViewCell
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        cell.imageView.image = nil
        let object = fetchedResultController!.object(at: indexPath) as? Images
        if object?.image == nil
        {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async
            {
                let url = URL(string:(object?.url)!)
                let imageData = try? Data(contentsOf: url!)
                self.fetchedResultController?.managedObjectContext.perform
                {
                    object!.image = imageData! as NSData
                    try! self.delegate.stack.saveContext()
                    cell.imageView.image = UIImage(data: (object?.image)! as Data)
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                }
            }
        }
        else
        {
            cell.imageView.image = UIImage(data: (object?.image)! as Data)
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
        }
        return cell
    }
    
    func obtainUrls(_ completion: @escaping(_ obtained: Bool, _ error: String?)-> Void)
    {
        let flickr = FlickrData()
        flickr.obtainData(longitude: self.point.longitude, latitude: self.point.latitude, page: Int32(arc4random_uniform(50)), completion: {
            error, urlArray in
            if error != nil
            {
                completion(false, error)
                return
            }
            if urlArray?.count == 0
            {
                completion(false, "ERROR: No data found!")
                return
            }
            for index in urlArray!
            {
                let image = Images(image: nil, point: self.point, context: (self.fetchedResultController?.managedObjectContext)!)
                image.url = index
            }
            completion(true, nil)
        })
    }
    
    func alertError(error: String)
    {
        DispatchQueue.main.async
        {
            let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
                alert in
                self.collectionButton.isEnabled = true
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

