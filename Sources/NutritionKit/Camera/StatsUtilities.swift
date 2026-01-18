//
// StatsUtilities.swift
//
// Nov 23rd, 2025.
//
// Jude Wilson (hi@judes.club), LiftKit (LiftKit.app)
//

import Foundation

public struct StatsUtilities {
    /// Returns a function f(x) = m*x + b fit by least-squares to the provided points.
    /// - Parameters:
    ///   - xs: X values.
    ///   - ys: Y values; must be same count as `xs`.
    /// - Returns: A closure mapping x -> y using the fitted line.
    public static func linearRegression(_ xs: [Double], _ ys: [Double]) -> (Double) -> Double {
        guard xs.count == ys.count, xs.count > 0 else {
            let meanY = ys.isEmpty ? 0.0 : (ys.reduce(0, +) / Double(ys.count))
            return { _ in meanY }
        }

        let n = Double(xs.count)
        let meanX = xs.reduce(0, +) / n
        let meanY = ys.reduce(0, +) / n

        var sxx = 0.0
        var sxy = 0.0
        for i in 0..<xs.count {
            let dx = xs[i] - meanX
            sxx += dx * dx
            sxy += dx * (ys[i] - meanY)
        }

        // If variance in x is ~0, fall back to constant function at meanY
        if sxx.isZero {
            return { _ in meanY }
        }

        let m = sxy / sxx
        let b = meanY - m * meanX
        return { x in m * x + b }
    }
}