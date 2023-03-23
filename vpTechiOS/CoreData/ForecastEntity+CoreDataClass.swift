//
//  ForecastEntity+CoreDataClass.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 22/03/2023.
//
//

import Foundation
import CoreData

@objc(ForecastEntity)
public class ForecastEntity: NSManagedObject {
    
    struct Forecast: Codable {
        let dt: Double
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Double
        let dtTxt: String
        
        init(entity: ForecastEntity) {
            self.dt = entity.date!.timeIntervalSince1970
            self.main = Main(temp: entity.temp, tempMin: entity.tempMin, tempMax: entity.tempMax, humidity: entity.humidity)
            self.weather = [Weather(description: entity.weatherDescription ?? "", icon: "")]
            self.clouds = Clouds(all: 0)
            self.wind = Wind(speed: 0, deg: 0, gust: 0)
            self.visibility = 0
            self.dtTxt = ""
        }
    }
    
    struct ForecastEntityAdapter: Codable {
        let dt: Double
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Double
        let dtTxt: String
        
        init(entity: ForecastEntity) {
            self.dt = entity.date!.timeIntervalSince1970
            self.main = Main(temp: entity.temp, tempMin: entity.tempMin, tempMax: entity.tempMax, humidity: entity.humidity)
            self.weather = [Weather( description: entity.weatherDescription ?? "", icon: "")]
            self.clouds = Clouds(all: 0)
            self.wind = Wind(speed: 0, deg: 0, gust: 0)
            self.visibility = 0
            self.dtTxt = ""
        }
    }
    
    struct ForecastEntityDecoder: Decoder {
        var codingPath: [CodingKey] = []
        var userInfo: [CodingUserInfoKey : Any] = [:]
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            
            fatalError("Not implemented")
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            
            fatalError("Not implemented")
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return ForecastEntitySingleValueDecoder()
        }
    }
    
    struct ForecastEntitySingleValueDecoder: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []
        
        func decodeNil() -> Bool {
            return false
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            guard let entity = codingPath.last as? ForecastEntity else {
                throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid type"))
            }
            return Forecast(entity: entity) as! T
        }
    }
}

