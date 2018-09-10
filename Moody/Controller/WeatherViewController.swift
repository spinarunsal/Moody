//
//  ViewController.swift
//  WeatherApp
//
//  Created by Pinar Unsal on 1/05/2018.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Foundation

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}


class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, ChangeCityDelegate {

    

    var arr = [UIImage(named: "fog"), UIImage(named: "dunno"),UIImage(named: "left"), UIImage(named: "tstorm1")]
    var dayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var weekDay : String = ""
    var messageArray : [WeatherDataModel] = [WeatherDataModel]()
    var messageArrayIndex : Int = 0
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "19cd1d1d61b0146102338b25ee504cdb"
    
    let FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    let tableMessageCell = CustomMessageCell()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var switchDegree: UISwitch!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekDay = getWeekdays()
        
        //TODO:Set up the tableView manager here.
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //TODO:Set up the location manager here.
        locationManager.delegate =  self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        switchDegree.setOn(false, animated: false)
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        forecastTableView.addGestureRecognizer(tapGesture)
        
        
        //TODO: Step 3 Register MessageCell.xib file here:
        forecastTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")

        
        //TODO: Configure tableView
        configureTableView()
        forecastTableView.separatorStyle = .none
        
    }


    //MARK: - TableView Weekdays
    /***************************************************************/
    
    func getWeekdays () -> String{
        
       /* let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter.string(from: date)
        print("Current date is \(currentDateString)")*/
        
        //print(Date().dayOfWeek()!)
        print("Today is : **************************************************")
        
        return Date().dayOfWeek()!
    }
    
    
    //MARK: - TableView DataSource Methods
    /***************************************************************/
    //TODO: Declare getDate method here:
    func getDate(dayText: Double) -> String {
        
        let date = Date(timeIntervalSince1970: dayText)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.none //Set date style
        let localDate = dateFormatter.string(from: date)
        print("localDate in getDate() \(date)")
        //dateFormatter.timeZone = NSTimeZone()
        
        return localDate
    
    }
    //TODO: Declare getTimeInfo method here: 5 PM
    func getTimeInfo (timeInfo:String) -> String {
        //Get time as 4 or 12
        let timeStringArr = timeInfo.components(separatedBy: ":")
        //Get dayTime as AM or PM
        let dayTime = timeStringArr[2].components(separatedBy: " ")
        
        return timeStringArr[0] + " " + dayTime[1]
    }
    
    //TODO: Step 1 Declare cellForRowAtIndexPath method here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //Step 2 dequeueReusableCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        //Make UIViewTable background transparent
        cell.layer.backgroundColor = UIColor.clear.cgColor
        if let url = URL(string: messageArray[indexPath.row].apiIcon){
            do {
                let data = try Data(contentsOf: url)
                cell.weatherIcon.image = UIImage(data: data)
            }catch let err {
                print("Error : \(err)")
            } 
        }
        //Call function getTimeInfo
        cell.day.text = getTimeInfo(timeInfo: messageArray[indexPath.row].localDateString)

        cell.firstTemperature = Int(Double(messageArray[indexPath.row].temperature))
        if switchDegree.isOn == false {
            cell.temperatureLabelCell.text = "\(cell.firstTemperature)°C"
        } else {
            let result = Double(cell.firstTemperature) + 32
            cell.temperatureLabelCell.text = "\(result)°F"
        }
        return cell
        
        
        
        
    }
    
    //TODO: Declare numberOfRowsInSection method here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func clearTableView (indexPath: IndexPath) {
        forecastTableView.deleteRows(at: [indexPath], with: .middle)
    }
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        forecastTableView.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        forecastTableView.rowHeight = UITableViewAutomaticDimension
        forecastTableView.estimatedRowHeight = 50.0
    }
    
    /***************************************************************/
    //MARK: - CollectionView DataSource Methods
    /***************************************************************/

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.layer.backgroundColor = UIColor.clear.cgColor
        //print("Im here--------------------------")

        //cell.labelText.text = self.messageArray[indexPath.item].city
        
        if let url = URL(string: messageArray[indexPath.item ].apiIcon){
            do {
                let data = try Data(contentsOf: url)
                cell.cellimage.image = UIImage(data: data)
            }catch let err {
                print("Error : \(err)")
            }
        }
        
        cell.firstTemperature = Int(Double(messageArray[indexPath.row].temperature))
        if switchDegree.isOn == false {
            cell.tempLabel.text = "\(cell.firstTemperature)°C"
        } else {
            let result = Double(cell.firstTemperature) + 32
            cell.tempLabel.text = "\(result)°F"
        }
        
        //Call function getTimeInfo
        cell.timeLabel.text = getTimeInfo(timeInfo: messageArray[indexPath.row].localDateString)
        
        return cell
        
    }
    
    /***************************************************************/
    //MARK: - Networking
    /***************************************************************/
    
    //TODO: Write the getWeatherData method here:
    //gets a string and a dictionary value [String: String]
    func getWeatherData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                //json conversation JSON() comes from SwiftyJSON
                let weatherJSON : JSON = JSON(response.result.value!)
               // print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    func getForecastData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            forecastResponse in
            if forecastResponse.result.isSuccess {
                print("Success! Got the weather data")
                
                //json conversation JSON() comes from SwiftyJSON
                let forecastJSON : JSON = JSON(forecastResponse.result.value!)
                self.updateForecastWeatherData(json: forecastJSON)
                print(forecastJSON)
                self.getForecast(foreCastJSON: forecastJSON)
            }
            else {
                //print("Error \(String(describing: forecastResponse.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    func getForecast (foreCastJSON: JSON) {
        // empty array for foreCast data from foreCastJSON
        var foreCastArray = [String]()
        
        for i in foreCastJSON {
            
        }
        
        
        
    }
    
    /***************************************************************/
    //MARK: - JSON Parsing
    /***************************************************************/

    //TODO: Write the updateForecastWeatherData method here:
    func updateForecastWeatherData(json : JSON) {
        //Check if json returns value
        if json["list"][0]["main"]["temp"].double != nil {
            //clean the array before re-write data
            self.messageArray.removeAll()
            
            //Read data from the OpenWeather API
            for i in 0...7 {
                
            let fcast = WeatherDataModel()
            fcast.temperature = Int(json["list"][i]["main"]["temp"].double! - 273.15)
            fcast.city = weatherDataModel.city
            fcast.countryCode = json["country"].stringValue
            fcast.condition = json["list"][i]["weather"][0]["id"].intValue

            

            let appIconStringValue = json["list"][i]["weather"][0]["icon"].stringValue
            fcast.apiIcon = "http://openweathermap.org/img/w/\(appIconStringValue).png"
             
            fcast.unixFormatOfDate = json["list"][i]["dt"].doubleValue
                let dateString = getDate(dayText: fcast.unixFormatOfDate)
             /*   print("fcast.unixFormofDate \(fcast.unixFormatOfDate)")
                print("fcast.daytaxt \(dateString)")*/
                
            fcast.localDateString = getDate(dayText: fcast.unixFormatOfDate)
                print("fcast.localDateString \(fcast.localDateString)")
                
            print("fcast.local after get \(fcast.localDateString)")
                
            self.messageArray.append(fcast)
           /*  print("fcast First temp: \(fcast.temperature)")
             print("icon name: \(fcast.weatherIconName)")
             print("icon condition: \(fcast.condition)")
             print("city name: \(fcast.city)")*/
               
                OperationQueue.main.addOperation {
                    self.forecastTableView.reloadData()
                    self.collectionView.reloadData()
                }
                
            }
            
            let a = messageArray.count
            for i in 0...39 {
                let fmodel = WeatherDataModel()
                
                
            }
        }
        else {
            cityLabel.text = "Weather Unavailable!"
        }
    }
    

    //TODO: Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        //check if json returns value
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            
            weatherDataModel.countryCode = json["sys"]["country"].stringValue
            let appIconStringValue = json["weather"][0]["icon"].stringValue
            
           /* weatherDataModel.apiIcon = "http://openweathermap.org/img/w/\(appIconStringValue).png"*/
            
        
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
            
            weatherDataModel.minTemp = json["main"]["temp_min"].intValue
            weatherDataModel.maxTemp = json["main"]["temp_max"].intValue
            weatherDataModel.humidity = json["main"]["humidity"].intValue
            
            weatherDataModel.windSpeed = json["wind"]["speed"].doubleValue
            
            
            // Sunset
            weatherDataModel.unixFormatOfDate = json["sys"]["sunset"].doubleValue
            
            weatherDataModel.getSunSet = getDate(dayText: weatherDataModel.unixFormatOfDate)
            //print("fcast.localDateString \(weatherDataModel.getSunSet)************************")
            
            
            //Sunrise
            weatherDataModel.unixFormatOfDate = json["sys"]["sunrise"].doubleValue
            
            weatherDataModel.getSunRise = getDate(dayText: weatherDataModel.unixFormatOfDate)
            //print("fcast.localDateString \(weatherDataModel.getSunRise)************************")
            
            
            
            weatherDataModel.weatherDescription = json["weather"][0]["description"].stringValue
            //print("\(weatherDataModel.weatherDescription) ------------------------------")
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable!"
        }
    }


    /***************************************************************/
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //TODO: Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        let result = Int(Double(weatherDataModel.temperature) + 32)
        let minResult = Int((Double(weatherDataModel.minTemp) - 273.15) + 32)
        let maxResult = Int((Double(weatherDataModel.maxTemp) - 273.15) + 32)
        if switchDegree.isOn == true {
            temperatureLabel.text = "\(result)°F"
            minTemp.text = "\(minResult)°F"
            maxTemp.text = "\(maxResult)°F"
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperature)°C"
            minTemp.text = "\((Double(weatherDataModel.minTemp) - 273.15))°C"
            maxTemp.text = "\((Double(weatherDataModel.maxTemp) - 273.15))°C"
        }
        cityLabel.text = "\(weatherDataModel.city), \(weatherDataModel.countryCode)"
         if let url = URL(string: weatherDataModel.apiIcon){
        //if let url = URL(string: weatherDataModel.weatherIconName)
            
            
     
        humidity.text = "\(weatherDataModel.humidity)%"
            
        sunset.text = "\(weatherDataModel.sunset)"
            
        wind.text = "\(weatherDataModel.windSpeed) km/h"
        sunrise.text = "\(weatherDataModel.getSunRise)"
        sunset.text = "\(weatherDataModel.getSunSet)"
        weatherDescription.text = "\(weatherDataModel.weatherDescription)"
            do {
                let data = try Data(contentsOf: url)
                weatherIcon.image = UIImage(data: data)
            }catch let err {
                print("Error : \(err)")
            }
        }
      
        /********************************!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
        weatherIcon.image = UIImage(named:weatherDataModel.weatherIconName)
    }

    /***************************************************************/
    //MARK: - Togglebar to switch degree C - F
    /***************************************************************/

    @IBAction func switchDegree(_ sender: UISwitch) {
        updateUIWithWeatherData()
        forecastTableView.reloadData()
        self.collectionView.reloadData()
    }
    
    /***************************************************************/
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //TODO: Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locations array holds all locations, we need last/current location
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            //dictionary
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            getForecastData(url: FORECAST_WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable!"
    }
    
    
    
    /***************************************************************/
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //TODO: Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        //customMessageCell
        getForecastData(url: FORECAST_WEATHER_URL, parameters: params)
        
    }
    
    //TODO: Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            //data type of segue Destionation is gonna be the ChangeCityViewController
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    } 
    
    
    
    
   
}



