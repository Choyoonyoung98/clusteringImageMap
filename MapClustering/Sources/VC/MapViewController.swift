//
//  MapViewController.swift
//  MapClustering
//
//  Created by Yoo Hwa Park on 2020/05/11.
//  Copyright © 2020 Yoo Hwa Park. All rights reserved.
//

import UIKit
import NMapsMap

public let primaryColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 1)

class MapViewController: UIViewController {
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField : UITextField!

    var mapView: NMFMapView {
        return naverMapView.mapView
    }
    
    var restaurants = [Restaurant]()
    let category: [Food] = [
        Food(category: .korean, foodImg: "ic_korean_food"),
        Food(category: .chinese, foodImg: "ic_chinese_food"),
        Food(category: .japanese, foodImg: "ic_japanese_food"),
        Food(category: .world, foodImg: "ic_global_food"),
        Food(category: .western, foodImg: "ic_western_food"),
        Food(category: .cafe, foodImg: "ic_cafe"),
        Food(category: .pub, foodImg: "ic_pub"),
        Food(category: .other, foodImg: "ic_other_food")
    ]
    var categoryCentroids = [String:Centroid]()
    
    let cellIdentifier = "CategoryCVCell"
    
    let picker = UIImagePickerController()
    
    var markers = [NMFMarker]()
    var centerMarkers = [NMFMarker]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        setMap()
        getPositionData()
        setStyle()
        
        searchTextField.returnKeyType = .search
        mapView.addCameraDelegate(delegate: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          self.view.endEditing(true)
    }
    
    func setMap() {
        mapView.positionMode = .direction
        naverMapView.showScaleBar = true
        naverMapView.showZoomControls = true
        naverMapView.showLocationButton = true
        naverMapView.showIndoorLevelPicker = true
        
        mapView.minZoomLevel = 5
        mapView.maxZoomLevel = 18
    }
    
    func getPositionData() {
        if let url = Bundle.main.url(forResource: "restaurant-list-for-test", withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
    }
    
    private func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonRestaurants = try? decoder.decode(Restaurants.self, from: json) {
            restaurants = jsonRestaurants.places
        }
    }
    
    var categoryCpyLocations = [Vector]()
    var imageExistingRestaurant = [Vector : [String : String]]()
    
    func markerSetting(by restaurants: [Restaurant]) {
        restaurants.forEach {
            let marker = NMFMarker(position: NMGLatLng(lat: $0.lat, lng: $0.lng))
            marker.captionText = $0.name

            if let url = $0.imageUrl {
                marker.userInfo = ["url" : url]
                let nameAndURL = ["name" : $0.name, "url" : url]
                imageExistingRestaurant[Vector([$0.lat, $0.lng])] = nameAndURL
            } else {
                marker.userInfo = ["imageName" : "ic_defaultFood"]
            }
            
            markers.append(marker)
            
            categoryCpyLocations.append(Vector([$0.lat, $0.lng]))
        }
    }
    
    
    func addCategoryMarkers(with category: BigCategory) {
        clearMarkers()
        
        let filteredRestaurants = restaurants.filter { $0.bigCategory.contains(category) }
        markerSetting(by: filteredRestaurants)
    }
    
    func addNameMarkers(with keyword: String) {
        clearMarkers()
        
        let filteredRestaurants = restaurants.filter { $0.name.contains(keyword) || $0.category.contains(keyword) }
        markerSetting(by: filteredRestaurants)
    }
    
    func findCenteroid(with categoryText: String) {
        var numClusters = markers.count / 10 > 1 ? markers.count / 10 + 1 : markers.count
        if numClusters > 20 { numClusters = 20 }

        print("numClusters ", numClusters)
        guard let kmm = KMeans(centroidCnt: numClusters) else { return }
        kmm.trainCenters(categoryCpyLocations, convergeDistance: 10)
        let clusterDict = kmm.fit(categoryCpyLocations)
        
        categoryCentroids[categoryText] = Centroid(kmeans: kmm, clusterDict: clusterDict)

        setCentroidMarkers(kmm: kmm, categoryText: categoryText)
    }
    
    func setCentroidMarkers(kmm: KMeans, categoryText: String) {
        print("\nCenters")
        kmm.centroids.forEach {
            guard let clusteredItems = categoryCentroids[categoryText]?.clusterDict[$0] else { return }
            setCenterMarker(centroid: $0, clusteredItems: clusteredItems)
        }
    }
    
    func setCenterMarker(centroid: Vector, clusteredItems: [Vector]) {
        let centerMarker = NMFMarker(position: NMGLatLng(lat: centroid.data[0], lng: centroid.data[1]))
        let coveredMarkers: [NMFMarker] = []
        centerMarker.captionText = String(clusteredItems.count)
        centerMarker.captionTextSize = 20
        centerMarker.iconImage = NMFOverlayImage(image: UIImage(named: "ic_centroid")!)
        centerMarker.captionAligns = [NMFAlignType.center]
        centerMarker.zIndex = clusteredItems.count
        centerMarker.userInfo = ["size": clusteredItems.count, "coveredMarkers": coveredMarkers]
        if let clusterSize = centerMarker.userInfo["size"] as? Int {
            centerMarker.width = CGFloat(Double(clusterSize) * 0.3 + 70)
            centerMarker.height = CGFloat(Double(clusterSize) * 0.3 + 70)
        }
        centerMarker.mapView = mapView
        centerMarkers.append(centerMarker)
    }
    
    private func clearMarkers() {
        markers.forEach { $0.mapView = nil }
        markers.removeAll()
        centerMarkers.forEach { $0.mapView = nil }
        centerMarkers.removeAll()
        categoryCpyLocations.removeAll()
        imageExistingRestaurant.removeAll()
    }
    
    @IBAction func selectPhotoAction(_ sender: Any) {
        let alert =  UIAlertController(title: "사진 선택/촬영", message: "찾고 싶은 음식을 선택해주세요!", preferredStyle: .actionSheet)

        let library =  UIAlertAction(title: "사진앨범", style: .default) { _ in
            self.openLibrary()
        }
        
        let camera =  UIAlertAction(title: "카메라", style: .default) { _ in
            self.openCamera()
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary() {
      picker.sourceType = .photoLibrary
      present(picker, animated: false, completion: nil)
    }

    func openCamera() {
      picker.sourceType = .camera
      present(picker, animated: false, completion: nil)
    }
    
    func setStyle() {
        self.searchView.round(radius: 5)
        self.searchView.customShadow(width: 1, height: 2, radius: 1, opacity: 0.1)
    }
}
