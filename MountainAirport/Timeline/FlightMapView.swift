

import SwiftUI
import MapKit

struct FlightMapView: UIViewRepresentable {
  var startCoordinate: CLLocationCoordinate2D
  var endCoordinate: CLLocationCoordinate2D
  var progress: CGFloat
	
	func makeUIView(context: Context) -> MKMapView {
	  let view = MKMapView(frame: .zero)
	  view.delegate = context.coordinator
	  return view
	}

	func makeCoordinator() -> MapCoordinator {
	  MapCoordinator(self, progress: progress)
	}

	func updateUIView(_ view: MKMapView, context: Context) {
		let startOverlay = MKCircle(
		  center: startCoordinate,
		  radius: 10000.0
		)
		let endOverlay = MKCircle(
		  center: endCoordinate,
		  radius: 10000.0
		)
		let flightPath = MKGeodesicPolyline(
		  coordinates: [startCoordinate, endCoordinate],
		  count: 2
		)
		view.addOverlays([startOverlay, endOverlay, flightPath])

	  // 1
	  let startPoint = MKMapPoint(startCoordinate)
	  let endPoint = MKMapPoint(endCoordinate)

	  // 2
	  let minXPoint = min(startPoint.x, endPoint.x)
	  let minYPoint = min(startPoint.y, endPoint.y)
	  let maxXPoint = max(startPoint.x, endPoint.x)
	  let maxYPoint = max(startPoint.y, endPoint.y)

	  // 3
	  let mapRect = MKMapRect(
		 x: minXPoint,
		 y: minYPoint,
		 width: maxXPoint - minXPoint,
		 height: maxYPoint - minYPoint
	  )
	  // 4
	  let padding = UIEdgeInsets(
		 top: 10.0,
		 left: 10.0,
		 bottom: 10.0,
		 right: 10.0
	  )
	  // 5
	  view.setVisibleMapRect(
		 mapRect,
		 edgePadding: padding,
		 animated: true
	  )
	  // 6
	  view.mapType = .mutedStandard
	  view.isScrollEnabled = false
	}
}

class MapCoordinator: NSObject {
  var mapView: FlightMapView
  var fraction: CGFloat

  init(
	 _ mapView: FlightMapView,
	 progress: CGFloat = 0.0
  ) {
	 self.mapView = mapView
	 self.fraction = progress
  }
}

extension MapCoordinator: MKMapViewDelegate {
  func mapView(
	 _ mapView: MKMapView,
	 rendererFor overlay: MKOverlay
  ) -> MKOverlayRenderer {
	 if overlay is MKCircle {
		let renderer = MKCircleRenderer(overlay: overlay)
		renderer.fillColor = UIColor.black
		renderer.strokeColor = UIColor.black
		return renderer
	 }

	 if overlay is MKGeodesicPolyline {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(
		  red: 0.0,
		  green: 0.0,
		  blue: 1.0,
		  alpha: 0.3
		)
		renderer.lineWidth = 3.0
		renderer.strokeStart = 0.0
		renderer.strokeEnd = fraction
		return renderer
	 }

	 return MKOverlayRenderer()
  }
}



struct MapView_Previews: PreviewProvider {
  static var previews: some View {
	 FlightMapView(
		startCoordinate: CLLocationCoordinate2D(
		  latitude: 35.655, longitude: -83.4411
		),
		endCoordinate: CLLocationCoordinate2D(
		  latitude: 36.0840, longitude: -115.1537
		),
		progress: 0.67
	 )
	 .frame(width: 300, height: 300)
  }
}

