import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/secrets.dart';
import 'package:weather_app/weather_forecsat_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double tempreature = 0;
  bool isLoading = false;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Bangalore';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeaterApiKey'));
      // print("Api state");
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An Unexpected Error Occured";
      }
      return data;
      // tempreature = data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
    // if()
    // print(res.body);
  }

  @override
  Widget build(BuildContext context) {
    // print("uild state");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            setState(() {});
          }, icon: const Icon(Icons.refresh)),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          // print(snapshot);
          // print(snapshot.runtimeType);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.hasError.toString());
          }
          final data = snapshot.data!;
          final currentWatherData = data['list'][0];
          final currentTemp = currentWatherData['main']['temp'];
          final currentSky = currentWatherData['weather'][0]['main'];
          final currentPressure = currentWatherData['main']['pressure'];
          final currentHumidity = currentWatherData['main']['humidity'];
          final currentWindSpeed = currentWatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                  currentSky == 'Cloud' || currentSky == 'Mist'
                                      ? Icons.cloud
                                      : currentSky == 'Rain'
                                          ? Icons.beach_access
                                          : Icons.wb_sunny,
                                  size: 64),
                              const SizedBox(height: 16),
                              Text(
                                "$currentSky",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Weather Forecast
                const SizedBox(height: 20),
                const Text(
                  "Weather Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ///Scrollable List View
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 10; i++)
                //         HourlyForecastItem(
                // time: data['list'][i + 1]['dt'].toString(),
                // icon: data['list'][i + 1]['weather'][0]['main'] ==
                //             'Clouds' ||
                //         data['list'][i + 1]['weather'][0]['main'] ==
                //             'Rain'
                //     ? Icons.cloud
                //     : Icons.sunny,
                // temperature:
                //     data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky = hourlyForecast['weather'][0]['main'];
                        final hourlyTemp = hourlyForecast['main']['temp'];
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecastItem(
                          time: DateFormat.Hm().format(time),
                          temperature: hourlyTemp.toString(),
                          icon: hourlySky == 'Cloud' || hourlySky == 'Mist'
                              ? Icons.cloud
                              : hourlySky == 'Rain'
                                  ? Icons.beach_access
                                  : Icons.wb_sunny,
                        );
                      }),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Additional Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItme(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$currentHumidity',
                    ),
                    AdditionalInfoItme(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$currentWindSpeed',
                    ),
                    AdditionalInfoItme(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: '$currentPressure',
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
