//
//  WeatherForecast.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 22/03/2023.
//
import Foundation

struct WeatherForecast: Codable {
    let list: [Forecast]
}

struct Forecast: Codable {
    let dt: Double
    let main: Main
    let weather: [Weather]
    let visibility: Double
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case visibility
        case dtTxt = "dt_txt"
    }
}

struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Clouds: Codable {
    let all: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
    let gust: Double
}

