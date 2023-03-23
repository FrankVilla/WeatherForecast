//
//  WeatherService.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 22/03/2023.
//

import Foundation
import Combine

enum WeatherServiceError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

struct WeatherService {
    
    let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    let apiKey = "YOU API KEY"
    
    func fetchWeatherForecast(latitude: Double, longitude: Double) -> AnyPublisher<WeatherForecast, WeatherServiceError> {
        
        guard let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)") else {
            return Fail(error: WeatherServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> WeatherServiceError in
                .networkError(error)
            }
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw WeatherServiceError.invalidResponse
                }
                return data
            }
            .decode(type: WeatherForecast.self, decoder: JSONDecoder())
            .mapError { error -> WeatherServiceError in
                .decodingError(error)
            }
            .eraseToAnyPublisher()
    }
}

