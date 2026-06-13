import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/blocProviders.dart';
import 'package:rabbit_flutter/src/domain/utils/FirebasePushNotifications.dart';
import 'package:rabbit_flutter/src/injection.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/LoginPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/RegisterPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/admin_dashboard_page.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/create_driver/admin_create_driver_page.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/drivers/admin_drivers_list_page.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/delete_driver/admin_delete_driver_page.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/profile/admin_profile_page.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/ClientDriverOffersPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/home/ClientHomePage.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/ClientMapBookingInfoPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/ClientMapTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/ClientRatingTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/DriverClientRequestsPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/DriverHomePage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/DriverMapTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/DriverRatingTripPage.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/ProfileUpdatePage.dart';
import 'package:rabbit_flutter/src/presentation/pages/roles/RolesPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await requestFcmPermission();
    await setupFlutterNotifications();
  }

  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    onMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(
        builder: FToastBuilder(),
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: "login",
        routes: {
          "login": (BuildContext context) => LoginPage(),
          "register": (BuildContext context) => RegisterPage(),
          "roles": (BuildContext context) => RolesPage(),
          "admin/home": (BuildContext context) => const AdminDashboardPage(),
          "admin/drivers/create": (BuildContext context) =>
              const AdminCreateDriverPage(),
          "admin/drivers/list": (BuildContext context) =>
              const AdminDriversListPage(),
          "admin/drivers/delete": (BuildContext context) =>
              const AdminDeleteDriverPage(),
          "admin/profile": (BuildContext context) => const AdminProfilePage(),
          "client/home": (BuildContext context) => ClientHomePage(),
          "driver/home": (BuildContext context) => DriverHomePage(),
          "client/map/booking": (BuildContext context) => ClientMapBookingInfoPage(),
          "profile/update": (BuildContext context) => ProfileUpdatePage(),
          "client/driver/offers": (BuildContext context) => ClientDriverOffersPage(),
          "client/map/trip": (BuildContext context) => ClientMapTripPage(),
          "driver/map/trip": (BuildContext context) => DriverMapTripPage(),
          "driver/rating/trip": (BuildContext context) => DriverRatingTripPage(),
          "driver/client/request": (BuildContext context) => DriverClientRequestsPage(),
          "client/rating/trip": (BuildContext context) => ClientRatingTripPage(),
        },
      ),
    );
  }
}