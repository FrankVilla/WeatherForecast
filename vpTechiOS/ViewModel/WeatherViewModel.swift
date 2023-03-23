//
//  WeatherViewModel.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 20/03/2023.
//

import Foundation
import Combine
import CoreData
import Network

class WeatherViewModel {
    
    private let weatherService: WeatherService
    private var cancellables: Set<AnyCancellable> = []
    private var managedObjectContext: NSManagedObjectContext
    private let monitor = NWPathMonitor()
    
    // Inputs
    let city: String
    let latitude: Double
    let longitude: Double
    
    // Outputs
    @Published var forecast: [Forecast] = []
    
    init(city: String = "Paris", latitude: Double = 48.8566, longitude: Double = 2.3522, weatherService: WeatherService = WeatherService(), managedObjectContext: NSManagedObjectContext) {
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.weatherService = weatherService
        self.managedObjectContext = managedObjectContext
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("We're connected!")
                self.fetchWeatherForecast()
            } else {
                self.loadSavedForecasts(managedObjectContext: managedObjectContext)
                print("No connection.")
            }
            print(path.isExpensive)
        }
    }
    
    func numberOfItems() -> Int {
        return forecast.count
    }
    
    func forecast(for indexPath: IndexPath) -> Forecast? {
        guard indexPath.row < forecast.count else { return nil }
        return forecast[indexPath.row]
    }
    
    func fetchWeatherForecast() {
        weatherService.fetchWeatherForecast(latitude: latitude, longitude: longitude)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching weather forecast: \(error)")
                case .finished:
                    print("Weather forecast fetch complete.")
                }
            }, receiveValue: { weatherForecast in
                self.forecast = weatherForecast.list
                self.saveForecasts(self.forecast)
            })
            .store(in: &cancellables)
    }
    
    func loadSavedForecasts(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<ForecastEntity> = ForecastEntity.fetchRequest()
        
        do {
            let forecastEntities = try managedObjectContext.fetch(fetchRequest)
            print("Forecasts saved to Core Data: \(forecastEntities)")
            
            var forecasts: [Forecast] = []
            for entity in forecastEntities {
                let forecast = Forecast(
                    dt: Double(entity.date?.timeIntervalSince1970 ?? 0),
                    main: Main(
                        temp: entity.temp,
                        tempMin: entity.tempMin,
                        tempMax: entity.tempMax,
                        humidity: Double(entity.humidity)
                    ),
                    weather: [
                        Weather(
                            description: entity.weatherDescription ?? "",
                            icon: entity.iconName ?? ""
                        )
                    ],
                    visibility: entity.visibility,
                    dtTxt: entity.description
                )
                forecasts.append(forecast)
            }
            
            self.forecast = forecasts
            
        } catch {
            print("Error loading saved forecasts from Core Data: \(error)")
        }
    }
    
    func saveForecasts(_ forecasts: [Forecast]) {
        
        managedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<ForecastEntity> = ForecastEntity.fetchRequest()
                try self.managedObjectContext.fetch(fetchRequest).forEach { forecastEntity in
                    self.managedObjectContext.delete(forecastEntity)
                }
                
                for forecast in forecasts {
                    let forecastEntity = ForecastEntity(context: self.managedObjectContext)
                    forecastEntity.date = Date(timeIntervalSince1970: forecast.dt)
                    forecastEntity.temp = forecast.main.temp
                    forecastEntity.tempMin = forecast.main.tempMin
                    forecastEntity.tempMax = forecast.main.tempMax
                    forecastEntity.humidity = Double(forecast.main.humidity)
                    forecastEntity.visibility = forecast.visibility
                    if let weather = forecast.weather.first {
                        forecastEntity.weatherDescription = weather.description
                    } else {
                        forecastEntity.weatherDescription = ""
                    }
                }
                
                try self.managedObjectContext.save()
                let savedForecastRequest: NSFetchRequest<ForecastEntity> = ForecastEntity.fetchRequest()
                let savedForecasts = try self.managedObjectContext.fetch(savedForecastRequest)
                
            } catch {
                print("Error saving forecasts to Core Data: \(error)")
            }
        }
    }
}
