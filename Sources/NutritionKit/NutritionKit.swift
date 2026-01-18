
import Toolbox

extension Log {
    static let nutritionKit = Logger(subsystem: "com.jonaszell.NutritionKit", category: "NutritionKit")
}

struct Logger {
    init(subsystem: String, category: String) {}
    func log(_ message: String) {}
    func info(_ message: String) {}
    func debug(_ message: String) {}
    func error(_ message: String) {}
    // Add other log levels as needed
}

