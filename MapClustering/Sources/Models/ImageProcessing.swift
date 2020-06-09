//
//  ImageProcessing.swift
//  MapClustering
//
//  Created by Yoo Hwa Park on 2020/05/15.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import UIKit
import NMapsMap
import Kingfisher

class ImageProcessing {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void ) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func resizeImage(image: UIImage, size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()
        return newImage
    }
    
     func downloadImage(from url: URL, in marker: NMFMarker, to mapView: NMFMapView) {
        let cache = ImageCache.default
        
        DispatchQueue.global().async {
            let cached = cache.isCached(forKey: url.absoluteString)
            let resource = ImageResource(downloadURL: url)
            
            if cached {
                print("ALREADY DOWNLOAD")
                cache.retrieveImage(forKey: url.absoluteString, completionHandler: {result in
                    switch result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            if let image = value.image {
                                let newImage = self.resizeImage(image: image, size: 60)
                                marker.iconImage = NMFOverlayImage(image: newImage)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                })
            } else {
                print("START DOWNLOAD")
                KingfisherManager.shared.retrieveImage(with: resource, completionHandler: {(result) in
                    let image = try? result.get().image
                    DispatchQueue.main.async {
                        if let image = image {
                            let newImage = self.resizeImage(image: image, size: 60)
                            marker.iconImage = NMFOverlayImage(image: newImage)
                        }
                        print("FINISH DOWNLOAD")
                    }
                })
            }
        }
    }
}
