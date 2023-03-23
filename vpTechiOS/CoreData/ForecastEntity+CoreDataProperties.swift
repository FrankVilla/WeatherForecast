//
//  ForecastEntity+CoreDataProperties.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 22/03/2023.
//
//

import Foundation
import CoreData
import UIKit

extension ForecastEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ForecastEntity> {
        return NSFetchRequest<ForecastEntity>(entityName: "ForecastEntity")
    }
    @NSManaged var weatherDescription: String?
    @NSManaged var tempMin: Double
    @NSManaged var tempMax: Double
    @NSManaged var temp: Double
    @NSManaged var pressure: Double
    @NSManaged var iconName: String?
    @NSManaged var visibility: Double
    @NSManaged var cityName: String?
    @NSManaged var date: Date?
    @NSManaged var humidity: Double
}

extension ForecastEntity : Identifiable {

}
