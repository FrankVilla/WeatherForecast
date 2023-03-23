//
//  WeatherDetailViewController.swift
//  vpTechiOStask
//
//  Created by KOVIGROUP on 21/03/2023.
//

import UIKit

class WeatherDetailViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var forecast: Forecast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeatherData()
        configureIcon()
        configureView()
    }
    
    func configureIcon() {
        if let iconName = forecast?.weather.first?.icon {
            let iconUrl = "https://openweathermap.org/img/w/\(iconName).png"
            if let url = URL(string: iconUrl) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.iconImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
    
    func configureView() {
        
        guard let forecast = self.forecast else { return }
        
        let temperatureInCelsius = forecast.main.temp - 273.15
        temperatureLabel.text = "\(String(format: "%.2f", temperatureInCelsius))°C"
        
        let tempMinInCelsius = forecast.main.tempMin - 273.15
        tempMinLabel.text = "Min: \(String(format: "%.2f", tempMinInCelsius))°C"
        
        let tempMaxInCelsius = forecast.main.tempMax - 273.15
        tempMaxLabel.text = "Max: \(String(format: "%.2f", tempMaxInCelsius))°C"
        
        let timestamp = forecast.dt
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE h:mm a"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    func fetchWeatherData() {
        if let forecast = forecast {
            let temperatureInCelsius = forecast.main.temp - 273.15
            temperatureLabel.text = "\(String(format: "%.2f", temperatureInCelsius))°C"
            
            let tempMinInCelsius = forecast.main.tempMin - 273.15
            tempMinLabel.text = "Min: \(String(format: "%.2f", tempMinInCelsius))°C"
            
            let tempMaxInCelsius = forecast.main.tempMax - 273.15
            tempMaxLabel.text = "Max: \(String(format: "%.2f", tempMaxInCelsius))°C"
            
            descriptionLabel.text = forecast.weather.first?.description
            humidityLabel.text = "Humidity: \(forecast.main.humidity)%"
            visibilityLabel.text = "Visibility: \(forecast.visibility)m"
            
            let timestamp = forecast.dt
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE h:mm a"
            dateLabel.text = dateFormatter.string(from: date)
        }
    }
}
