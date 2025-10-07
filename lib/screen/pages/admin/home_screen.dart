import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../../providers/master_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<MasterProvider>(context, listen: false).loadUsersAndOwners();
      Provider.of<MasterProvider>(context, listen: false).loadVenuesAndFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<MasterProvider>(
        builder: (context, masterProvider, child) {
          if (masterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (masterProvider.chartData.isEmpty) {
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
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),

                // Welcome message
                Center(
                  child: Text(
                    "Welcome Back, Admin!",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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

                // Pie chart owner dan user
                SizedBox(
                  height: 250,
                  child: masterProvider.chartData.isNotEmpty
                      ? PieChart(
                          dataMap: masterProvider.chartData,
                          chartType: ChartType.disc,
                          legendOptions: LegendOptions(
                            legendPosition: LegendPosition.left,
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                          ),
                        )
                      : const Center(child: Text("No data available for owner/user chart.")),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: 10,
                ),

                // Pie chart venue dan field
                SizedBox(
                  height: 250,
                  child: masterProvider.chartDataVenueField.isNotEmpty
                      ? PieChart(
                          dataMap: masterProvider.chartDataVenueField,
                          chartType: ChartType.disc,
                          legendOptions: LegendOptions(
                            legendPosition: LegendPosition.left,
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                          ),
                          colorList: List.generate(masterProvider.chartDataVenueField.length, (index) {
                            return index.isEven ? Colors.amber : Colors.lightGreen;
                          }),
                        )
                      : const Center(child: Text("No data available for venue/field chart.")),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
