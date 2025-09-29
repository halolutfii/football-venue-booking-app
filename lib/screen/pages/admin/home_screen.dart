import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../../providers/user_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUsersAndOwners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.chartData.isEmpty) {
            return const Center(child: Text("No data available for the pie chart."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying the logo image
                Center(
                  child: Image.asset(
                    "assets/images/logo_screen.png",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),

                // Welcome message
                Center(
                  child: Text(
                    "Welcome Back, Admin!",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: 20,
                ),

                // Pie chart section
                SizedBox(
                  height: 250,
                  child: PieChart(
                    dataMap: userProvider.chartData, 
                    chartType: ChartType.disc, 
                    legendOptions: LegendOptions(
                      legendPosition: LegendPosition.left,
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                    ),
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: 20,
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
