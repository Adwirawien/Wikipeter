//
//  MapView.swift
//  Wikipeter
//
//  Created by Adrian Böhme on 28.04.20.
//  Copyright © 2020 Adrian Böhme. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var lm = LocationManager()
    @Binding var results: [Result]

    func updateUIView(_ view: MKMapView, context: Context) {
        // set the view once to the user
        if (lm.location?.latitude != nil && view.isRotateEnabled) {
            setViewToUser(view: view)
            view.isRotateEnabled = false;
        }

        for result in results {
            let landmark = LandmarkAnnotation(title: result.title, subtitle: "\(result.dist)m", coordinate: CLLocationCoordinate2D(latitude: result.lat, longitude: result.lon))
            view.addAnnotation(landmark)
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.isPitchEnabled = false
        return view;
    }

    func setViewToUser(view: MKMapView) {
        let coordinate = CLLocationCoordinate2D(
            latitude: lm.location?.latitude ?? 0, longitude: lm.location?.longitude ?? 0)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        view.showsUserLocation = true
    }
}

class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
