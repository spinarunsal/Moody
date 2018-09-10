//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Pinar Unsal on 1/05/2018.
//

import UIKit

//MARK: - protocol ChangeCityDelegate
/***************************************************************/
//Write the protocol declaration here:
protocol ChangeCityDelegate {
    func userEnteredANewCityName (city : String)
}

//MARK: - class ChangeCityViewController: UIViewController
/***************************************************************/
class ChangeCityViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate : ChangeCityDelegate?


    //This is the pre-linked IBOutlets to the text field:

    @IBOutlet weak var changeCityTextField: UITextField!

    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPresed(_ sender: Any) {
        
        //1 Get the city name the user entered in the text field
        let cityName = changeCityTextField.text!
        
        //2 If we have a delegate set, call the method userEnteredANewCityName
        //if delegate is not nill then call userEnterNewCityName
        //Optional chaining
        delegate?.userEnteredANewCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
        //3 dismiss the Change City View Controller to go back to the WeatherViewController
    
        
    }
    
    
    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    //MARK: - backButtonPressed
    /***************************************************************/
    @IBAction func backButtonPressed(_ sender: Any) {
                self.dismiss(animated: true, completion: nil)
    }

    
}
