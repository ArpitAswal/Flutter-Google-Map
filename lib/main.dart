import 'dart:async';
import 'dart:collection';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // in the below line, we are initializing our controller for google maps.
  final Completer<GoogleMapController> _controller = Completer();
  final CustomInfoWindowController windowController =
      CustomInfoWindowController(); // initializing the controller to customize the info window on marker

  final Set<Marker> _markerSet = {};
  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polylines = HashSet<Polyline>();
  final List<LatLng> _polyCoordinates = [];
  final loc.Location userLoc = loc.Location();

  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;

  late LatLng? _currentLocation;
  late String _mapStyleString;

  void _multiMarkers() {
    /*
    Each marker in the set expects some parameters, which are useful to convey the information. The first marker is given the info window,
    which shows its ID (you can write anything here to describe the place) and a rotation of 90 degrees. The rotation param is very useful when you have multiple markers at the same place.
     */
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker3"),
        position: const LatLng(28.755361884833104, 77.78933129915275),
        infoWindow: InfoWindow(
            title: "Hapur",
            onTap: () async {
              await showAddress(28.755361884833104, 77.78933129915275);
            }),
        rotation: 90));
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker4"),
        position: const LatLng(28.82892925652713, 77.56899103035926),
        infoWindow: InfoWindow(
            title: 'Yo China Modinagar',
            onTap: () async {
              await showAddress(28.82892925652713, 77.56899103035926);
              windowController.addInfoWindow!(
                  // it will display when user click on title of marker
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const CircularProgressIndicator();
                              },
                              "https://lh5.googleusercontent.com/p/AF1QipPhRmGh1T1N1dqq7ZMFv63e9zxt27ChQ-zlMXGF=w408-h306-k-no",
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text("Yo China Modinagar")),
                        const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 6.0),
                            child: Text("Fast Food Restaurant"))
                      ],
                    ),
                  ),
                  const LatLng(28.82892925652713, 77.56899103035926));
            })));
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker5"),
        position: const LatLng(28.798975211980494, 77.6181092467462),
        infoWindow: InfoWindow(
            title: 'Bhojpur Toll Plaza 2',
            onTap: () async {
              await showAddress(28.798975211980494, 77.6181092467462);
              windowController.addInfoWindow!(
                  // it will display when user click on title of marker
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                    child: SizedBox(
                                        width: 40,
                                        child: CircularProgressIndicator()));
                              },
                              "https://lh5.googleusercontent.com/p/AF1QipPhRmGh1T1N1dqq7ZMFv63e9zxt27ChQ-zlMXGF=w408-h306-k-no",
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text("Yo China Modinagar")),
                        const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 6.0),
                            child: Text("Fast Food Restaurant"))
                      ],
                    ),
                  ),
                  const LatLng(28.798975211980494, 77.6181092467462));
            })));
  }

  // created list of locations to display polygon, to draw polygons starting and ending point must be same
  List<LatLng> points = const [
    LatLng(28.855418265329643, 77.58909526476833),
    LatLng(28.798975211980494, 77.6181092467462),
    LatLng(28.82892925652713, 77.56899103035926),
    LatLng(28.855418265329643, 77.58909526476833),
  ];

  void _polygonPoints() {
    //initialize polygon
    _polygons.add(Polygon(
      // given polygonId
      polygonId: const PolygonId('Polygon1'),
      // initialize the list of points to display polygon
      points: points,
      // given color to polygon
      fillColor: Colors.green.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.green,
      strokeWidth: 4, // given width of border
      geodesic:
          true, //Indicates whether the segments of the polygon should be drawn as geodesics, as opposed to straight lines on the Mercator projection.
      // A geodesic is the shortest path between two points on the Earth's surface. The geodesic curve is constructed assuming the Earth is a sphere
    ));
  }

  void _polylinePoints() {
    _polylines.add(Polyline(
        polylineId: const PolylineId('Polyline1'),
        points: points,
        color: Colors.blue,
        width: 4));
    _polylines.add(Polyline(
        polylineId: const PolylineId('Polyline2'),
        points: _polyCoordinates,
        color: Colors.redAccent,
        width: 4));
    setState(() {});
  }

  void _getPolyPointsRoute() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Config.googleMapKey,
        const PointLatLng(28.855418265329643, 77.58909526476833),
        const PointLatLng(28.82892925652713, 77.56899103035926),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Meerut Rd")],
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          _polyCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _customMarker() {
    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/user_pic.png",
            width: 28, height: 28)
        .then((icon) {
      _currentLocationIcon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentLocation = null;
    _requestPermission();
    rootBundle
        .loadString('assets/map_style/standard_theme.json')
        .then((string) {
      _mapStyleString = string; // styling the google map style
    });
    _multiMarkers();
    _customMarker();
    _polygonPoints();
    _getPolyPointsRoute();
    _polylinePoints();
    _locationListener();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _getUserCurrentLocation();
    } else {
      // Handle the case where permission is denied.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permission is required to show Location button.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(children: [
                GoogleMap(
                  // in the below line, setting camera position, with the latitude and longitude of the location you want to display on the map.
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 14,
                  ),
                  // in the below line, specifying map type.
                  mapType: MapType.normal,
                  // in the below line, setting user location enabled.
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  // in the below line, setting compass enabled.
                  compassEnabled: true,
                  // You can turn on traffic mode by simply setting the value of trafficEnabled to true.
                  trafficEnabled: true,
                  tiltGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  style: _mapStyleString, //styling the google map theme
                  // in the below line, specifying controller on map complete.
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(
                        controller); //is a callback that’s called when the map is ready to use. It provides the GoogleMapController, which is really helpful for performing certain actions on the map.
                    windowController.googleMapController = controller;
                    if (_currentLocation != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentLocation!,
                            zoom: 14,
                          ),
                        ),
                      );
                    }
                  },
                  //Markers are a great way to show a particular location.
                  markers: _markerSet,
                  onTap: (pos) {
                    windowController
                        .hideInfoWindow!(); // when we tap on the map, if the info window is open it will hide the window
                  },
                  onCameraMove: (pos) {
                    windowController
                        .onCameraMove!(); // it will move the window little bit when the user moving into other location on map
                  },
                  polygons:
                      _polygons, //Polygons to represent routes or areas in Google Maps.
                  polylines:
                      _polylines, //Polylines to represent routes for various destinations on Google Maps.
                ),
                CustomInfoWindow(
                  // it will determine the dimension of each info window
                  controller: windowController,
                  height: 130,
                  width: 260,
                  offset: 50,
                ),
                PopupMenuButton(itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        onTap: () => rootBundle
                                .loadString(
                                    'assets/map_style/standard_theme.json')
                                .then((string) {
                              _mapStyleString = string;
                              setState(() {});
                            }),
                        child: const Text("Standard")),
                    PopupMenuItem(
                        onTap: () => rootBundle
                                .loadString('assets/map_style/retro_theme.json')
                                .then((string) {
                              _mapStyleString = string;
                              setState(() {});
                            }),
                        child: const Text("Retro")),
                    PopupMenuItem(
                        onTap: () => rootBundle
                                .loadString('assets/map_style/night_theme.json')
                                .then((string) {
                              _mapStyleString = string;
                              setState(() {});
                            }),
                        child: const Text("Night")),
                  ];
                })
              ]),
      ),
    );
  }

  Future<Placemark?> covertFromLatLong(double lat, double long) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, long);
    if (placeMarks[0].street != null) {
      return placeMarks[0];
    }
    return null;
  }

  Future<void> _getUserCurrentLocation() async {
    try {
      // Check service enabled and request if necessary
      bool serviceEnabled = await userLoc.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await userLoc.requestService();
        if (!serviceEnabled) {
          throw Exception("Location services are disabled.");
        }
      }

      // Check and request permissions
      loc.PermissionStatus permission = await userLoc.hasPermission();
      if (permission == loc.PermissionStatus.denied ||
          permission == loc.PermissionStatus.deniedForever) {
        permission = await userLoc.requestPermission();
        if (permission == loc.PermissionStatus.denied ||
            permission == loc.PermissionStatus.deniedForever) {
          throw Exception("Location permissions are denied.");
        }
      }

      // Get position
      await getPosition();
    } catch (e) {
      // Handle exceptions
      throw ("Error getting location: $e");
    }
  }

  Future<void> showAddress(double lat, double long) async {
    Placemark? address = await covertFromLatLong(lat, long);

    showModalBottomSheet(
      // context and builder are
      // required properties in this widget
      context: context,
      barrierColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      //enableDrag: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.8,
            shouldCloseOnMinExtent: false,
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: (address == null)
                    ? const Center(child: Text("Location Address Not Found"))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                    "${address.locality}, ${address.subLocality}"),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const CircleAvatar(
                                    radius: 14,
                                    child: Icon(Icons.clear),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "${lat.toStringAsFixed(5)}, ${long.toStringAsFixed(5)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(21))),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (index == 0) ...[
                                                const Icon(Icons.directions),
                                                const SizedBox(width: 6.0),
                                                const Text("Directions")
                                              ] else if (index == 1) ...[
                                                const Icon(Icons
                                                    .bookmark_border_rounded),
                                                const SizedBox(width: 6.0),
                                                const Text("Save")
                                              ] else if (index == 2) ...[
                                                const Icon(Icons.share_rounded),
                                                const SizedBox(width: 6.0),
                                                const Text("Share")
                                              ] else if (index == 3) ...[
                                                const Icon(
                                                    Icons.new_label_rounded),
                                                const SizedBox(width: 6.0),
                                                const Text("Add label")
                                              ] else ...[
                                                const Icon(
                                                    Icons.more_horiz_rounded),
                                                const SizedBox(width: 6.0),
                                                const Text("More")
                                              ]
                                            ])),
                                  );
                                },
                              ),
                            ),
                            _buildInfoRow(Icons.straighten, 'Measure Distance'),
                            _buildInfoRow(
                                Icons.location_on_rounded, '$lat, $long'),
                            _buildInfoRow(Icons.grid_3x3,
                                '${address.postalCode},${address.administrativeArea}'),
                            _buildInfoRow(
                                Icons.add_location_alt, 'Add a missing place'),
                          ],
                        ),
                      ),
              );
            });
      },
    );
  } // it will display the little bit information's that we could received from latitude and longitude

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPosition() async {
    // Get the current position
    userLoc.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        distanceFilter: 0.1,
        interval: 1000);
    userLoc.getLocation().then((location) {
      _currentLocation = LatLng(location.latitude!, location.longitude!);
      _markerSet.add(Marker(
        markerId: const MarkerId("Marker1"),
        position: LatLng(location.latitude!, location.longitude!),
        icon: _currentLocationIcon,
        infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: "User",
            onTap: () async {
              await showAddress(location.latitude!, location.longitude!);
            }),
        //rotation: 90
      ));
      setState(() {});
    });
  }

  void _locationListener() async {
    final GoogleMapController googleCnt = await _controller.future;

    userLoc.onLocationChanged.listen((change) {
      _currentLocation = LatLng(change.latitude!, change.longitude!);
      setState(() {
        googleCnt.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation!, zoom: 15)));
      });
    });
  }
}
