import Foundation

extension Date {
    
    public enum Error: Swift.Error {
        case couldNotParse
    }
    
    public static func parse(_ format: String, _ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    public func parse(_ date: String) -> Date {
        return Date.parse("yyyy-MM-dd HH:mm:ss", date)
    }
    
    public static func parseOrThrow(_ format: String, _ date: String?) throws -> Date {
        guard let dateString: String = date else {
            throw Error.couldNotParse
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let newDate = dateFormatter.date(from: dateString)
        
        guard let newDateUnw = newDate else {
            throw Error.couldNotParse
        }
        
        return newDateUnw
    }
   
    public func parseOrThrow(_ date: String?) throws -> Date {
        return try Date.parseOrThrow("yyyy-MM-dd HH:mm:ss", date)
    }
}
