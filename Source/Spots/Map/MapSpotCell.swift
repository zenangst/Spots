import UIKit
import Sugar
import MapKit

class MapSpotCell: UICollectionViewCell, Itemble {

  var size = CGSize(width: 88, height: 360)
  var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0,
      width: 200,
      height: 200))
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    return label
    }()

  lazy var mapView: MKMapView = {
    let mapView = MKMapView()
    mapView.contentMode = .ScaleAspectFill
    mapView.autoresizingMask = [.FlexibleWidth]
    mapView.scrollEnabled = false
    return mapView
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(mapView)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    mapView.frame = contentView.frame
    label.text = item.title

    let latitude = item.meta.property("latitude") ?? 0.0
    let longitude = item.meta.property("longitude") ?? 0.0

    mapView.centerCoordinate = CLLocationCoordinate2DMake(Double(latitude), Double(longitude))

    let span = MKCoordinateSpanMake(1, 1)
    let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
    mapView.setRegion(region, animated: false)
  }
}
