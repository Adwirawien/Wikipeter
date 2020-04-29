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
    var latitude: Double = 0
    var longitude: Double = 0
    typealias MethodAlias = (_ articleResult: Result) -> Void
    var loadArticle: MethodAlias?

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self, loadArticle ?? { _ in })
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = context.coordinator
        for result in results {
            addAnnotation(view, result)
        }

        // check if custom coordinates should be used
        if (latitude != 0) {
            setViewToCoordinates(view: view, latitude: latitude, longitude: longitude)
            view.isZoomEnabled = false
            view.isRotateEnabled = false
            view.isScrollEnabled = false
            return
        }

        // set the view once to the user
        if (lm.location?.latitude != nil && view.isRotateEnabled) {
            setViewToUser(view: view)
            view.isRotateEnabled = false;
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
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        view.showsUserLocation = true
    }

    func setViewToCoordinates(view: MKMapView, latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        view.showsUserLocation = true
    }

    func addAnnotation(_ view: MKMapView, _ result: Result) {
        let landmark = LandmarkAnnotation(result: result, title: result.title, subtitle: "\(result.dist)m", coordinate: CLLocationCoordinate2D(latitude: result.lat, longitude: result.lon))
        view.addAnnotation(landmark)
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapViewController: MapView
    typealias MethodAlias = (_ articleResult: Result) -> Void
    var loadArticle: MethodAlias

    init(_ control: MapView, _ loadArticle: @escaping MethodAlias) {
        self.mapViewController = control
        self.loadArticle = loadArticle
    }

    @objc func buttonClicked(sender: SubclassedUIButton) {
        loadArticle(sender.result!)
    }

    func mapView(_ mapView: MKMapView, viewFor
        annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LandmarkAnnotation else {
            return nil
        }

        let identifier = "location"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
                view.canShowCallout = true
                var button = SubclassedUIButton(type: .detailDisclosure)
                button.result = annotation.result
                button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                view.rightCalloutAccessoryView = button
        }
        return view

    }
}

class SubclassedUIButton: UIButton {
    var result: Result?
}

class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let result: Result

    init(result: Result,
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.result = result
    }
}
