//
//  Satisfiability.swift
//  
//
//  Created by Rowenna Emma and Kat on 10/3/21.
//

import Foundation
import CCryptoBoringSSL

typealias PartiallyColoredSATGraph = [UInt: (TruthColoring, [UInt])]

enum TruthColoring: UInt {
    case falseC = 0
    case truthC = 1
    case neutralC = 2
    case uncolored = 3
}

func makeSATGraph() -> PartiallyColoredSATGraph {
    return [TruthColoring.falseC.rawValue: (TruthColoring.falseC, [TruthColoring.truthC.rawValue, TruthColoring.neutralC.rawValue]),
            TruthColoring.truthC.rawValue: (TruthColoring.truthC, [TruthColoring.falseC.rawValue, TruthColoring.neutralC.rawValue]),
            TruthColoring.neutralC.rawValue: (TruthColoring.neutralC, [TruthColoring.falseC.rawValue, TruthColoring.truthC.rawValue])]
}

func attachNot(to base: PartiallyColoredSATGraph, at point: UInt) -> PartiallyColoredSATGraph? {
    guard let (colorP, _) = base[point] else {
        return nil
    }
    let notResult : TruthColoring
    switch colorP {
    case .truthC:
        notResult = .falseC
    case .falseC:
        notResult = .truthC
    case .uncolored:
        notResult = .uncolored
    case .neutralC:
        return nil
    }
    let notGraph: PartiallyColoredSATGraph = [0: (colorP, [1, 2]), 1: (notResult, [0, 2]), 2: (TruthColoring.neutralC, [0, 1])]
    return attachGraph(notGraph, to: base, matchingVertices: [0: point, 2: TruthColoring.neutralC.rawValue])
}

func attachGraph(_ addition: PartiallyColoredSATGraph, to base: PartiallyColoredSATGraph, matchingVertices: [UInt: UInt] ) -> PartiallyColoredSATGraph? {
    var newBase = base
    let bMax = newBase.keys.max() ?? 0
    
    for (vertexID, (colorA, edges)) in addition {
        let newEdges = edges.map { matchingVertices[$0] ?? $0 + bMax }
        
        if let matchingVertex = matchingVertices[vertexID] {
            guard let (colorB, edgesB) = newBase[matchingVertex] else {
                return nil  
            }
            let newColor : TruthColoring
            
            if colorA != .uncolored {
                if colorB != .uncolored {
                    guard colorA == colorB else {
                        return nil
                    }
                }
                newColor = colorA
            } else {
                newColor = colorB
            }
            newBase[matchingVertex] = (newColor, edgesB + newEdges)
        } else {
            newBase[vertexID + bMax] = (colorA, newEdges)
        }
    }
    
    return newBase
}

func coloredGraph(from partial: PartiallyColoredSATGraph) -> ColoredGraph? {
    var newGraph = ColoredGraph()
    
    for (vertexID, (color, edges)) in partial {
        let alteredColor : Colors
        switch color {
        case .falseC:
            alteredColor = .red
        case .truthC:
            alteredColor = .grn
        case .neutralC:
            alteredColor = .blu
        case .uncolored:
            return nil
        }
        
        newGraph[vertexID] = (alteredColor, edges)
    }
    
    return newGraph
}
