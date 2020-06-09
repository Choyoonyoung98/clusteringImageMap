//
//  MapViewControllerExtension.swift
//  MapClustering
//
//  Created by 조윤영 on 2020/05/17.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import Foundation
import UIKit
import NMapsMap

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CategoryCVCell
        
        cell?.titleLabel.text =  category[indexPath.row].category.rawValue
        let foodImgString = category[indexPath.row].foodImg
        cell?.imageView.image = UIImage(named: foodImgString)
        
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchTextField.text = ""
        
        addCategoryMarkers(with: category[indexPath.row].category)
        if categoryCentroids[category[indexPath.row].category.rawValue] == nil {
            findCenteroid(with: category[indexPath.row].category.rawValue)
        } else {
            //해당 카테고리에 대해서 수집된 centroid가 있다면,
            if let kmm = categoryCentroids[category[indexPath.row].category.rawValue]?.kmeans {
                setCentroidMarkers(kmm: kmm, categoryText: category[indexPath.row].category.rawValue)
            }
        }
        Clustering().calcZoomClustering(with: mapView, centerMarkers: centerMarkers)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let categoryText = category[indexPath.item].category.rawValue
        let width = CGFloat(56 + 13 * categoryText.count)
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
}

extension MapViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {

}

extension MapViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ searchTextField: UITextField) -> Bool {
        if let visibleCells = collectionView.visibleCells as? [CategoryCVCell] {
            visibleCells.forEach { $0.baseInnerView.layer.borderColor = UIColor.clear.cgColor }
        }
        
        searchTextField.resignFirstResponder()

        if let text = searchTextField.text {
            if text.count < 2 {
                let alertController = UIAlertController(title: "키워드 에러", message: "2글자 이상 키워드를 입력해주세요!", preferredStyle: .actionSheet)
                
                let okAction : UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                    print("OK pressed")
                })
                
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return false
            } else {
                addNameMarkers(with: text)
                guard !markers.isEmpty else { return true }
                if (categoryCentroids[text] == nil) {
                    findCenteroid(with: text)
                } else {
                    //해당 카테고리에 대해서 수집된 centroid가 있다면,
                    if let kmm = categoryCentroids[text]?.kmeans {
                        setCentroidMarkers(kmm: kmm, categoryText: text)
                    }
                }
                return true
            }
        }
        return false
    }
}

extension MapViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        //초기 줌레벨: 14
    }
    
    func innerBoundCheck(_ marker : NMFMarker,in bounding : NMGLatLngBounds) -> Bool {
        if (marker.position.lat >= bounding.southWest.lat &&
            marker.position.lat <= bounding.northEast.lat &&
            marker.position.lng >= bounding.southWest.lng &&
            marker.position.lng <= bounding.northEast.lng) {
            return true
        } else {
            return false
        }
    }
    
    func setMarkerImage(marker : NMFMarker) {
        if let url = marker.userInfo["url"] as? String {
                print("마커 위치", marker.position)
                if let imageURL = URL(string: url) {
                    DispatchQueue.global().async {
                        ImageProcessing().downloadImage(from:imageURL, in: marker, to: self.mapView)
                    }
                }
        } else {
            if let imageName = marker.userInfo["imageName"] as? String {
                marker.iconImage = NMFOverlayImage(image: UIImage(named: imageName)!)
            }
        }
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        print(mapView.zoomLevel)
        print("지도 바운딩 넓이", mapView.contentBounds)
        let bounding = mapView.contentBounds
        print("카메라 위치", mapView.cameraPosition)
        if mapView.zoomLevel == mapView.maxZoomLevel {
            for marker in markers {
                marker.mapView = mapView
                if (innerBoundCheck(marker, in: bounding)) {
                    setMarkerImage(marker: marker)
                }
            }
            centerMarkers.forEach { $0.mapView = nil }
        } else {
            markers.forEach { $0.mapView = nil }
            centerMarkers.forEach { $0.mapView = mapView }
        }
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        if mapView.zoomLevel != mapView.maxZoomLevel {
            Clustering().calcZoomClustering(with: mapView, centerMarkers: centerMarkers)
        }
    }
}
