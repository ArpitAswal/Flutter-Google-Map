# Project Title: Google Map Flutter

This project demonstrates the integration of Google Maps with the Flutter framework, showcasing various functionalities and features to create a dynamic map-based application. It incorporates essential map elements like markers, polygons, polylines, and user location tracking. Below is an overview of the key features and details of the implementation.

## Features

#### 1. Permissions
- Requests and manages location permissions using the permission_handler package.
- Ensures the location service is enabled before using map functionalities.
#### 2. Map Customization
- Implements multiple map styles (Standard, Retro, and Night) using JSON styling files.
- Styles are loaded dynamically and can be toggled through a popup menu.
#### 3. Markers
- Displays multiple markers on the map with: Custom InfoWindows for markers using the custom_info_window package. Custom icons for specific markers.
- Allows interaction with markers to show location-specific details.
#### 4. Polygons and Polylines
- Polygons: These are used to define areas on the map. Geodesic properties allow accurate rendering over the Earth's surface.
- Polylines: Draw routes between two or more points using the flutter_polyline_points package. Fetches and displays a path based on route data from the PolylinePoints API.
#### 5. User Location
- Tracks the user’s real-time location and updates the map dynamically using the location package.
- The map camera animates to follow the user’s updated position.
#### 6. Interactive InfoWindow
- Custom InfoWindows provide additional details such as: Images, names, and addresses of places. Options like directions, save, share, and add labels.
#### 7. Address Lookup
- Converts latitude and longitude into human-readable addresses using the geocoding package. Displays address details in a bottom sheet.

## Challenges

#### Understanding Map Widgets

- Issue: Grasping all the properties of the GoogleMap widget, such as markers, polylines, and polygons, felt complex initially.
- Solution: I started with a basic map implementation and gradually added one feature at a time, such as markers and polylines, testing each step to understand how they work.

#### Marker Customization

- Issue: Creating and scaling custom marker icons resulted in blurry icons or alignment issues.
- Solution: I carefully formatted assets to match the required resolution and used the BitmapDescriptor class to create high-quality custom markers.

#### Drawing Polygons and Polylines

- Issue: Defining the correct coordinates and ensuring shapes rendered properly on the map was challenging.
- Solution: I learned how to define LatLng points for these shapes and used debugging tools to verify that coordinates were accurate.

#### Real-Time Location Updates

- Issue: Continuously tracking and updating the user’s location while animating the camera was tricky to implement efficiently.
- Solution: I used the location package to fetch location updates and optimized performance by debouncing location changes to avoid excessive camera updates.

#### Error Handling

- Issue: Handling errors like invalid API keys or network issues without crashing the app required extra effort.
- Solution: I implemented try-catch blocks and added SnackBars to provide descriptive error messages, ensuring the app gracefully handled errors.

#### Performance Optimization

- Issue: Rendering multiple markers and handling real-time updates caused occasional lag.
- Solution: It is yet to be tackled but I will optimise the app by batching updates, using lightweight assets, and avoiding redundant UI redraws.

## Future Enhancements

- Advanced Search Features: Users can search for specific places or addresses directly on the map.
- Enhanced InfoWindow: Add interactive graphs, videos, or additional context to marker InfoWindows.
- Clustered Markers: Automatically group markers in high-density areas for cleaner map visualization.
- Multi-Stop Routing: Implement advanced route planning with multiple stops along the way.
  
## Installation

#### Clone the Repository: 
- git clone <repository_url>
#### Install Dependencies: 
- flutter pub get
#### Configure Google Maps API Key:
- Add your Google Maps API key in the Config.googleMapKey variable.
#### Run the App: 
- flutter run
    
## Note

- Use your Google Map Key by creating in Google Cloud and enabling Maps SDK for Android and iOS API and services.
- To use the features of Google Maps make sure you enable all the necessary permissions.
- Currently, all the permissions are active for only Android Devices.
- To run this application on iOS platforms make sure you add all the necessary permissions.

## Usage Flow

#### Launch the App:
- Displays a splash screen and requests location permissions.
- If permissions are denied, an error message appears, prompting users to enable them.
#### Map Display:
- Shows the map with the user’s current location.
- Users can toggle between map styles (Standard, Retro, Night).
#### Markers:
- Add multiple markers to the map.
- Tapping on markers displays their InfoWindow with interactive elements.
#### Routing:
- Draw routes between locations using PolylinePoints.
- Allows dynamic route creation based on the selected waypoints.
#### Dynamic Location Tracking:
- Continuously tracks and updates the user’s location.
- Animates the camera to follow the user.
  
## Packages Used

- google_maps_flutter: Integrates Google Maps into the Flutter application.
- custom_info_window: Customizes InfoWindows for map markers.
- flutter_polyline_points: Generates polylines for routes between coordinates.
- geocoding: Converts geographic coordinates into addresses.
- location: Accesses and tracks the user’s location.
- permission_handler	Manages permissions for location access.
- cupertino_icons: Provides additional icons for the user interface.
- flutter_plugin_android_lifecycle: Ensures compatibility with Android lifecycle changes.

## Tech Stack

- Flutter: The primary framework for building the mobile application.
- Dart: The programming language used with Flutter.
- Google Map Key: To run the map on devices.
  
## Feedback

- If you have any feedback, please reach out to me at arpitaswal995@gmail.com
- If you face an issue, then open an issue in a GitHub repository.
  
## Contributing

- Contributions are always welcome!

#### Fork the Repository:

- Go to the original repository on GitHub or GitLab.
- Click the "Fork" button. This creates a copy of the repository under your account.
  
#### Create a New Branch:
- Clone your forked repository to your local machine: git clone <your_fork_url>
- Create a new branch for your feature: git checkout -b feature-branch
- Replace feature-branch with a descriptive name for your changes (e.g., fix-bug, add-feature).
  
#### Make Changes and Commit:
- Make the necessary changes to the code in your local feature-branch.
- Stage the changes: git add <files> (or git add . to stage all changes)
- Commit the changes with a clear message: git commit -m "Add new feature"
- Use a descriptive and concise message that explains the changes.
  
#### Push Changes to Your Fork:
- Push your feature-branch to your remote repository: git push origin feature-branch
  
#### Create a Pull Request:
- Go back to the original repository on GitHub or GitLab.
- Click the "New Pull Request" button.
- Select your feature-branch as the source and the original repository's main or develop branch as the target.
- Provide a clear description of your changes and why they are needed.
- Submit the pull request.


## Conclusion

This project showcases a comprehensive implementation of Google Maps in Flutter, with features ranging from dynamic location tracking to interactive map elements like markers, polygons, and polylines. It provides a foundation for building sophisticated map-based applications with rich features and user-friendly designs.
