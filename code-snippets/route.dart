import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../login_screen/Login_screen.dart';
import '../login_screen/Verification_pending_screen.dart';
import '../pages/All-expence-view-screen/main_button_show_screen/all_expences_view_screen.dart';
import '../pages/All-expence-view-screen/model/trip_expences_all_models/trip_expences_model.dart';
import '../pages/All-expence-view-screen/widgets/editDeleteShare_expences_view_screens/edit_delete_share_trip_expences.dart';
import '../pages/All-expence-view-screen/widgets/view_trip_expences_reports_button.dart';
import '../pages/Expence-adding-screen/main-button-show-screen/expences_adding.dart';
import '../pages/Sales-details-adding-screen/sales_deatils_adding_screen.dart';
import '../widgets/utilities/main_navigation.dart';

class AppRouters {
  final GoRouter router = GoRouter(
    // This is the first screen GoRouter shows when app starts
    initialLocation: '/',
    // ✅ THIS handles auth check automatically
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final isOnLoginPage = state.matchedLocation == '/Loginpage';

      if (isLoggedIn && isOnLoginPage) {
        return '/homescreen'; // logged in but on login page → send to home(show the navigation)
      }

      if (!isLoggedIn && !isOnLoginPage) {
        return '/Loginpage'; // not logged in → send to login
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          // '/' just redirects based on auth, no widget needed
          final user = FirebaseAuth.instance.currentUser;
          return user != null ? '/homescreen' : '/Loginpage';
        },
      ),
      GoRoute(
        path: "/Loginpage",
        name: "Loginpage",
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: "/verificationPendingScreen",
        name: "verificationPendingScreen",
        builder: (context, state) {
          return const VerificationPendingScreen();
        },
      ),
      GoRoute(
        path: "/homescreen",
        name: "homescreen",
        builder: (context, state) {
          return const MainNavigation();
        },
      ),
      GoRoute(
        path: "/expencesAddingScreen",
        name: "expencesAddingScreen",
        builder: (context, state) {
          return const ExpencesAddingScreen();
        },
      ),
      GoRoute(
        path: "/allExpencesViewScreen",
        name: "allExpencesViewScreen",
        builder: (context, state) {
          return const AllExpencesViewScreen();
        },
      ),
      GoRoute(
        path: "/salesDetailsAddingScreen",
        name: "salesDetailsAddingScreen",
        builder: (context, state) {
          return const SalesDetailsAddingScreen();
        },
      ),
    
      //state.extra → full object (your case ✅)
      GoRoute(
        path: "/EditDeleteShareTripExpences",
        name: 'EditDeleteShareTripExpences',
        builder: (context, state) {
          final trip = state.extra as TripExpencesModel;

          return EditDeleteShareTripExpences(trip: trip);
        },
      ),
      GoRoute(
        path: "/ViewTripExpencesReports",
        name: 'ViewTripExpencesReports',
        builder: (context, state) {
          return const ViewTripExpencesReports();
        },
      ),
    ],
  );
}
