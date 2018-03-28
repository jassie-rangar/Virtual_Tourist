//
//  FlickrData.swift
//  Virtual Tourist
//
//  Created by Jaskirat Singh on 13/03/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import Foundation
import UIKit

struct FlickrData
{
    let scheme = "https"
    let host = "api.flickr.com"
    let path = "/services/rest"
    
    func obtainData(longitude: Double, latitude: Double, page: Int32, completion: @escaping (_ error: String?, _ data: [String]?) -> ())
    {
        let baseURL = "https://api.flickr.com/services/rest?page=\(page)&method=flickr.photos.search&format=json&api_key=4e17e4dda249815c53b3700489d74270&bbox=\(bBox(Latitude: latitude, Longitude: longitude))&extras=url_m&nojsoncallback=1"
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: baseURL)!) {
            data, responce, error in
            if error != nil
            {
                completion(error?.localizedDescription, nil)
                return
            }
            
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
            if let pics = jsonData["photos"] as? [String: Any], let pic = pics["photo"] as? [[String: Any]]
            {
                var count = pic.count - 1
                var UrlArray = [String]()
                if count > 20
                {
                    count = 20
                }
                while count > 0
                {
                    count = count - 1
                    let objCount = pic[count]
                    let picUrl = objCount["url_m"] as! String
                    UrlArray.append(picUrl)
                }
                completion(nil,UrlArray)
            }
        }
        task.resume()
    }
    
    func bBox(Latitude: Double, Longitude: Double)-> String
    {
    
        let minLong = min(Longitude + 1, 180)
        let maxLong = max(Longitude - 1, -180)
        let minLat = min(Latitude + 1, 90)
        let maxLat = max(Latitude - 1, -90)
        return "\(maxLong),\(maxLat),\(minLong),\(minLat)"
    }
    
}
