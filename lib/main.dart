import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:googlemap/places_json_model.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _searchController = TextEditingController();

  final Set<Marker> _markerSet = {};
  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polylines = HashSet<Polyline>();
  final List<LatLng> _polyCoordinates = [];
  final loc.Location userLoc = loc.Location();

  late LatLng? _currentLocation;
  late String _mapStyleString;

  // created list of locations to display polygon, to draw polygons starting and ending point must be same
  final List<LatLng> _points = const [
    LatLng(28.855418265329643, 77.58909526476833),
    LatLng(28.798975211980494, 77.6181092467462),
    LatLng(28.82892925652713, 77.56899103035926),
    LatLng(28.855418265329643, 77.58909526476833),
  ];

  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
  List<Predictions> _placeList = [];

  void _multiMarkers() {
    /*
    Each marker in the set expects some parameters, which are useful to convey the information. The first marker is given the info window,
    which shows its ID (you can write anything here to describe the place) and a rotation of 90 degrees. The rotation param is very useful when you have multiple markers at the same place.
     */
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker2"),
        position: const LatLng(28.729681986165, 77.78510346601946),
        infoWindow: InfoWindow(
            title: "Hapur",
            onTap: () async {
              await showAddress(28.729681986165, 77.78510346601946);
              windowController.addInfoWindow!(
                  // it will display when user click on title of marker
                  windowContainer(),
                  const LatLng(28.729681986165, 77.78510346601946));
            }),
        rotation: 90));
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker3"),
        position: const LatLng(28.82892925652713, 77.56899103035926),
        infoWindow: InfoWindow(
            title: 'Yo China Modinagar',
            onTap: () async {
              await showAddress(28.82892925652713, 77.56899103035926);
              windowController.addInfoWindow!(
                  // it will display when user click on title of marker
                  windowContainer(
                      img:
                          "https://lh5.googleusercontent.com/p/AF1QipPhRmGh1T1N1dqq7ZMFv63e9zxt27ChQ-zlMXGF=w408-h306-k-no",
                      title: "Yo China Modinagar",
                      subtitle: "Fast Food Restaurant"),
                  const LatLng(28.82892925652713, 77.56899103035926));
            })));
    _markerSet.add(Marker(
        markerId: const MarkerId("Marker4"),
        position: const LatLng(28.798975211980494, 77.6181092467462),
        infoWindow: InfoWindow(
            title: 'Bhojpur Toll Plaza 2',
            onTap: () async {
              await showAddress(28.798975211980494, 77.6181092467462);
              windowController.addInfoWindow!(
                  // it will display when user click on title of marker
                  windowContainer(
                      img:
                          "https://lh5.googleusercontent.com/p/AF1QipPhRmGh1T1N1dqq7ZMFv63e9zxt27ChQ-zlMXGF=w408-h306-k-no",
                      title: "Yo China Modinagar",
                      subtitle: "Fast Food Restaurant"),
                  const LatLng(28.798975211980494, 77.6181092467462));
            })));
  }

  void _polygonPoints() {
    //initialize polygon
    _polygons.add(Polygon(
      polygonId: const PolygonId('Polygon1'), // given polygonId

      points: _points, // initialize the list of points to display polygon

      fillColor: Colors.green.withOpacity(0.3), // given color to polygon

      //strokeColor: Colors.green, // given border color to polygon
      strokeWidth: 4, // given width of border
      geodesic:
          true, //Indicates whether the segments of the polygon should be drawn as geodesics, as opposed to straight lines on the Mercator projection.
      // A geodesic is the shortest path between two points on the Earth's surface. The geodesic curve is constructed assuming the Earth is a sphere
    ));
  }

  void _polylinePoints() {
    //initialize polyline
    _polylines.add(Polyline(
        polylineId: const PolylineId('Polyline1'), // given polylineId
        points: _points, // initialize the list of points to display polyline

        color: Colors.blue, // given color to polyline
        width: 4 // given width of border
        ));
    _polylines.add(Polyline(
        polylineId: const PolylineId('Polyline2'),
        points: _polyCoordinates,
        color: Colors.redAccent,
        width: 4));
  }

  void _getPolyPointsRoute() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Config.googleMapKey, // your Google Map API key
        const PointLatLng(
            28.855418265329643, 77.58909526476833), // source coordinates
        const PointLatLng(
            28.82892925652713, 77.56899103035926), //destination coordinates
        travelMode: TravelMode
            .driving, // travel mode such as driving, walking, cycling etc.
        wayPoints: [
          PolylineWayPoint(location: "Goivndpuri Modinagar via Meerut Rd"),
          PolylineWayPoint(location: "Modi Mandir Modinagar via Meerut Rd")
        ],
        //An array of PolylineWayPoint objects to specify intermediate waypoints along the route.
        // Each PolylineWayPoint can either have a location (address string) or latLng (coordinates).
      );

      //The result object contains information about the calculated route: points: A list of PointLatLng objects representing the coordinates of the polyline.
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          _polyCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // You can display an error message to the user here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found')),
        );
      }
    } catch (e) {
      if (e is SocketException) {
        // Handle network issues (e.g., no internet connection)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network error. Please check your connection.')),
        );
      } else if (e is TimeoutException) {
        // Handle timeouts
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Request timed out. Please try again later.')),
        );
      } else if (e.toString().contains('key')) {
        // Handle potential API key issues (this is a heuristic check)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or missing API key.')),
        );
      } else {
        // Handle other unknown errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    }
  }

  void _customMarker() {
    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/user_pic.png",
            width: 40, height: 40)
        .then((icon) {
      _currentLocationIcon = icon;
    });
  }

  void _locationListener() async {
    userLoc.onLocationChanged.listen((change) {
      _currentLocation = LatLng(change.latitude!, change.longitude!);
      setState(() {});
    });
  }

  void _onChanged() {
    if (_searchController.text.isNotEmpty &&
        _searchController.text.length >= 3) {
      getSuggestion(_searchController.text);
    }
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
    _searchController.addListener(() {
      _onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : (_searchController.text.isEmpty)
                  ? GoogleMap(
                      // in the below line, setting camera position, with the latitude and longitude of the location you want to display on the map.
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation ??
                            const LatLng(28.82892925652713, 77.56899103035926),
                        zoom: 14,
                      ),

                      mapType: MapType
                          .normal, // in the below line, specifying map type.
                      myLocationEnabled:
                          true, // setting user location enabled. animates to focus on the user's current location if the user's location is currently known.
                      myLocationButtonEnabled:
                          true, //The my-location button causes the camera to move such that the user's location is in the center of the map.
                      compassEnabled:
                          true, // in the below line, setting compass enabled.
                      trafficEnabled:
                          true, // You can turn on traffic mode by simply setting the value of trafficEnabled to true.
                      tiltGesturesEnabled:
                          true, //True if the map view should respond to tilt gestures.
                      scrollGesturesEnabled:
                          true, //True if the map view should respond to scroll gestures.
                      zoomGesturesEnabled:
                          true, //True if the map view should respond to zoom gestures.
                      style: _mapStyleString, //styling the google map theme
                      // in the below line, specifying controller on map complete.
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(
                            controller); //is a callback that’s called when the map is ready to use. It provides the GoogleMapController, which is really helpful for performing certain actions on the map.
                        windowController.googleMapController = controller;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _currentLocation!,
                              zoom: 14,
                            ),
                          ),
                        );
                      },
                      markers:
                          _markerSet, //Markers are a great way to show a particular location.
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
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        alignment: Alignment.center,
                        child: (_placeList.isEmpty)
                            ? const Center(child: Text("No Places Exist"))
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0.0),
                                  itemCount: _placeList.length,
                                  itemBuilder: (context, index) {
                                    final place = _placeList[index];
                                    return ListTile(
                                      title: Text(place.description!.trim()),
                                      onTap: () => _selectPlace(
                                          place.placeId!, place.description!),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: (_searchController.text.isEmpty) ? 55.0 : 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search places...",
                    focusColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: const Icon(Icons.location_searching),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.text = "";
                        setState(() {
                          _placeList = [];
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          CustomInfoWindow(
            // it will determine the dimension of each info window
            controller: windowController,
            height: 130,
            width: 260,
            offset: 50,
          ),
          Positioned(
            bottom: (_searchController.text.isEmpty) ? 90 : 20,
            right: 10,
            child: PopupMenuButton(
                iconSize: 32,
                itemBuilder: (context) {
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
                }),
          )
        ]),
      ),
    );
  }

  Widget windowContainer(
      {dynamic img = "", String title = "", String subtitle = ""}) {
    return Container(
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                height: 100,
                width: MediaQuery.of(context).size.width,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Image.asset(
                      "assets/images/bot_image.jpg",
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.fill,
                    ),
                  );
                },
                img,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Text(title)),
          Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
              child: Text(subtitle))
        ],
      ),
    );
  }

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

  Future<Placemark?> placemarkFromLatLong(double lat, double long) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location Error: ${e.toString()}')),
      );
    }
  }

  Future<void> showAddress(double lat, double long) async {
    Placemark? address = await placemarkFromLatLong(lat, long);

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
                                    "${address.locality}, ${address.administrativeArea}, ${address.country}"),
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
                            Text("${address.street}"),
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

  Future<void> getPosition() async {
    // Get the current position
    userLoc.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        distanceFilter:
            0.1, //means that a new location update will be triggered if the device moves by at least 0.1 meters.
        interval:
            3000); //minimum time interval (in milliseconds) between location updates. updates will occur at least every 3000 milliseconds (3 second).
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
      ));
      setState(() {});
    });
  }

  Future<void> _requestPermission() async {
    try {
      var status = await Permission.location.status;
      // Handle the case where permission is denied.
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.location.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          throw ("Location permission is required to show Location button.");
        }
      }
      _getUserCurrentLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> getSuggestion(String input) async {
    try {
      String baseURL =
          'https://maps.gomaps.pro/maps/api/place/queryautocomplete/json';
      String request = '$baseURL?input=$input&key=${Config.googleMapPlacesKey}';
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        _placeList =
            PlacesModel.fromJson(jsonDecode(response.body)).predictions!;
        setState(() {});
      } else {
        throw Exception(
            'Failed to load predictions, response status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Places Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectPlace(String placeID, String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final Placemark? landmark = await placemarkFromLatLong(
          locations.first.latitude, locations.first.longitude);
      setState(() {
        _currentLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        _markerSet.add(Marker(
          markerId: MarkerId(placeID),
          position: _currentLocation!,
          infoWindow: InfoWindow(
              title: "${landmark!.locality}, ${landmark.name}",
              snippet: landmark.administrativeArea,
              onTap: () {
                showAddress(
                    locations.first.latitude, locations.first.longitude);
                //fetch location details such as marker image, address, place name etc. and display in window container
              }),
        ));
        _placeList = [];
        _searchController.text = "";
      });
    }
  }
}

/*
final PlacesModel cacheData = PlacesModel.fromJson({
  "predictions": [
    {
      "description": "pizza near Paris, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text": "near Paris, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Paris"},
        {"offset": 18, "value": "France"}
      ]
    },
    {
      "description":
      "pizza near Pari Chowk, NRI City, Omega II, Noida, Uttar Pradesh, India",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Pari Chowk, NRI City, Omega II, Noida, Uttar Pradesh, India",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Pari Chowk"},
        {"offset": 23, "value": "NRI City"},
        {"offset": 33, "value": "Omega II"},
        {"offset": 43, "value": "Noida"},
        {"offset": 50, "value": "Uttar Pradesh"},
        {"offset": 65, "value": "India"}
      ]
    },
    {
      "description":
      "pizza near Disneyland Park, Disneyland Drive, Anaheim, CA, USA",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 22}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Disneyland Park, Disneyland Drive, Anaheim, CA, USA",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 16}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Disneyland Park"},
        {"offset": 28, "value": "Disneyland Drive"},
        {"offset": 46, "value": "Anaheim"},
        {"offset": 55, "value": "CA"},
        {"offset": 59, "value": "USA"}
      ]
    },
    {
      "description":
      "pizza near Cathédrale Notre-Dame de Paris, Parvis Notre-Dame - place Jean-Paul-II, Paris, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 36}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Cathédrale Notre-Dame de Paris, Parvis Notre-Dame - place Jean-Paul-II, Paris, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 30}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Cathédrale Notre-Dame de Paris"},
        {"offset": 43, "value": "Parvis Notre-Dame - place Jean-Paul-II"},
        {"offset": 83, "value": "Paris"},
        {"offset": 90, "value": "France"}
      ]
    },
    {
      "description":
      "pizza near Paris Beauvais Airport, Route de l'Aéroport, Tillé, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Paris Beauvais Airport, Route de l'Aéroport, Tillé, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Paris Beauvais Airport"},
        {"offset": 35, "value": "Route de l'Aéroport"},
        {"offset": 56, "value": "Tillé"},
        {"offset": 63, "value": "France"}
      ]
    },
    {
      "description": "pizza near Paris, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text": "near Paris, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Paris"},
        {"offset": 18, "value": "France"}
      ]
    },
    {
      "description":
      "pizza near Pari Chowk, NRI City, Omega II, Noida, Uttar Pradesh, India",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Pari Chowk, NRI City, Omega II, Noida, Uttar Pradesh, India",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Pari Chowk"},
        {"offset": 23, "value": "NRI City"},
        {"offset": 33, "value": "Omega II"},
        {"offset": 43, "value": "Noida"},
        {"offset": 50, "value": "Uttar Pradesh"},
        {"offset": 65, "value": "India"}
      ]
    },
    {
      "description":
      "pizza near Disneyland Park, Disneyland Drive, Anaheim, CA, USA",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 22}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Disneyland Park, Disneyland Drive, Anaheim, CA, USA",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 16}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Disneyland Park"},
        {"offset": 28, "value": "Disneyland Drive"},
        {"offset": 46, "value": "Anaheim"},
        {"offset": 55, "value": "CA"},
        {"offset": 59, "value": "USA"}
      ]
    },
    {
      "description":
      "pizza near Cathédrale Notre-Dame de Paris, Parvis Notre-Dame - place Jean-Paul-II, Paris, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 36}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Cathédrale Notre-Dame de Paris, Parvis Notre-Dame - place Jean-Paul-II, Paris, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 30}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Cathédrale Notre-Dame de Paris"},
        {"offset": 43, "value": "Parvis Notre-Dame - place Jean-Paul-II"},
        {"offset": 83, "value": "Paris"},
        {"offset": 90, "value": "France"}
      ]
    },
    {
      "description":
      "pizza near Paris Beauvais Airport, Route de l'Aéroport, Tillé, France",
      "matched_substrings": [
        {"length": 5, "offset": 0},
        {"length": 3, "offset": 11}
      ],
      "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "reference": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
      "structured_formatting": {
        "main_text": "pizza",
        "main_text_matched_substrings": [
          {"length": 5, "offset": 0}
        ],
        "secondary_text":
        "near Paris Beauvais Airport, Route de l'Aéroport, Tillé, France",
        "secondary_text_matched_substrings": [
          {"length": 3, "offset": 5}
        ]
      },
      "terms": [
        {"offset": 0, "value": "pizza"},
        {"offset": 6, "value": "near"},
        {"offset": 11, "value": "Paris Beauvais Airport"},
        {"offset": 35, "value": "Route de l'Aéroport"},
        {"offset": 56, "value": "Tillé"},
        {"offset": 63, "value": "France"}
      ]
    }
  ],
  "status": "OK"
}); */
