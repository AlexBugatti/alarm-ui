//
//  APIService.swift
//  alarm-swift-ui
//
//  Created by Александр on 10.07.2022.
//

import Foundation

class APIService {
    
    static func getPokemon(order: Int, completion: @escaping ((Pokemon?) -> Void)) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(order)")
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            
            var object: Pokemon?
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let obj = try decoder.decode(Pokemon.self, from: data)
                    object = obj
                } catch let _ {
                    
                }
            }
            
            completion(object)
        }
        task.resume()
    }
    
    static func getList(completion: @escaping (([PokemonItem]) -> Void)) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151")
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            
            var object: [PokemonItem] = []
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let obj = try decoder.decode(PokemonResponse.self, from: data)
                    object = obj.results
                } catch _ {
                    
                }
            }
            
            completion(object)
        }
        task.resume()
    }
    
}
