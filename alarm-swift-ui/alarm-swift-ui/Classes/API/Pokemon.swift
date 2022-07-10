//
//  Pokemon.swift
//  alarm-swift-ui
//
//  Created by Александр on 10.07.2022.
//

import Foundation

struct Pokemon: Codable {
    let name: String
    let sprites: Sprites
}

struct PokemonItem: Codable, Identifiable, Hashable {
    let id: String = UUID().uuidString
    let name: String
    let url: String
}

struct PokemonResponse: Codable {
    let results: [PokemonItem]
}

struct Sprites: Codable {
    let other: Other
}

struct Other: Codable {
    let dream_world: DreamWorld
    let home: DreamWorld
}

struct DreamWorld: Codable {
    let front_default: String
}
