//
//  WeatherCollectionViewCell.swift
//  vpTechiOStask
//
//  Created by KOVIGROUP on 21/03/2023.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    func configure(with forecast: Forecast) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: forecast.dtTxt) {
            let dayOfWeekFormatter = DateFormatter()
            dayOfWeekFormatter.dateFormat = "EEEE"
            let dayOfWeek = dayOfWeekFormatter.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let time = timeFormatter.string(from: date)
            dateLabel.text = "\(dayOfWeek) at \(time)"
        }
        
        let temperatureInCelsius = forecast.main.temp - 273.15
        temperatureLabel.text = "\(String(format: "%.2f", temperatureInCelsius))°C"
        descriptionLabel.text = forecast.weather.first?.description
        
        // Load image from URL
        if let icon = forecast.weather.first?.icon, let url = URL(string: "https://openweathermap.org/img/w/\(icon).png") {
            
            if let icon = forecast.weather.first?.icon {
                var imageName: String
                switch icon {
                case "01d", "01n":
                    imageName = "Sunny"
                case "02d", "02n", "03d", "03n", "04d", "04n":
                    imageName = "Cloudy"
                case "09d", "09n":
                    imageName = "HeavyRain"
                case "10d", "10n":
                    imageName = "LightRain"
                case "11d", "11n":
                    imageName = "StrongWind"
                case "13d", "13n":
                    imageName = "Snow"
                case "50d", "50n":
                    imageName = "LightWind"
                default:
                    imageName = "OffLineMode"
                }
    
                if let image = UIImage(named: imageName) {
                    self.backgroundImageView.image = image
                }
            }
            
            let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let data = data, error == nil else {
                    print("Failed to load image from URL: \(url)")
                    return
                }
                DispatchQueue.main.async {
                    self?.iconImageView.image = UIImage(data: data)
                }
            }
            dataTask.resume()
        }
    }
}
