//
//  WeatherDataModel.swift
//  WeatherApp
//
//
//  Created by Pinar Unsal on 1/05/2018.
//

import UIKit

class WeatherDataModel: UIViewController {

    //Declare your model variables here
    var temperature : Int = 0

    var condition : Int = 0
    var city : String = ""
    var countryCode : String = ""
    var weatherIconName : String = ""
    var unixFormatOfDate : Double = 0
    var apiIcon : String = ""
    var localDateString : String = ""
    var minTemp : Int = 0
    var maxTemp : Int = 0
    var humidity: Int = 0
    var sunset: String = ""
    var windSpeed: Double = 0
    var sunrise: String = ""
    var weatherDescription: String = ""
    var getSunSet: String = ""
    var getSunRise: String = ""

    
    //This method turns a condition code into the name of the weather condition image
    
    func updateWeatherIcon(condition: Int) -> String {
        print("weather data model condition: \(condition)")
    switch (condition) {
    
        case 0...300 :
            return "tstorm1"
        
        case 301...500 :
            return "light_rain"
        
        case 501...600 :
            return "shower3"
        
        case 601...700 :
            return "snow4"
        
        case 701...771 :
            return "fog"
        
        case 772...799 :
            return "tstorm3"
        
        case 800 :
            return "sunny"
        
        case 801...804 :
            return "cloudy2"
        
        case 900...903, 905...1000  :
            return "tstorm3"
        
        case 903 :
            return "snow5"
        
        case 904 :
            return "sunny"
        
        default :
            return "dunno"
        }

    }
}
