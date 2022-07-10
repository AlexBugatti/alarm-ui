//
//  OffView.swift
//  alarm-swift-ui
//
//  Created by Александр on 10.07.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct OffView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var pokemons: [PokemonItem] = []
    @State var points: Int = 0
    @State var pokemon: Pokemon?
    @State var items: [PokemonItem] = []
    
    var body: some View {
        VStack {
            Text("Это что за покемон?")
                .font(Font.system(size: 24, weight: .medium, design: .default))
            Text("\(points)/5")
            WebImage(url: URL(string: pokemon?.sprites.other.home.front_default ?? ""))
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width, alignment: .top)
            List {
                ForEach(items, id: \.self) { item in
                    Button {
                        self.checkAnswer(item: item)
                    } label: {
                        Text(item.name.capitalized)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .onAppear {
            getPokemon()
        }
    }
    
    func getPokemon() {
        let randorOrder = Int.random(in: 1...110)
        APIService.getPokemon(order: randorOrder) { pokemon in
            if let pokemon = pokemon {
                self.getList(pokemon: pokemon)
                self.pokemon = pokemon
            }
        }
    }
    
    func getList(pokemon: Pokemon) {
        guard pokemons.count == 0 else {
            generateList(pokemon: pokemon, list: self.pokemons)
            return
        }
        
        APIService.getList { items in
            self.generateList(pokemon: pokemon, list: items)
        }
    }
    
    func generateList(pokemon: Pokemon, list: [PokemonItem]) {
        var items = list
        var pokemons: [PokemonItem] = []
        pokemons.append(PokemonItem(name: pokemon.name, url: ""))
        for _ in 0...2 {
            let random = Int.random(in: 0..<items.count)
            pokemons.append(items[random])
            items.remove(at: random)
        }
        self.items = pokemons.shuffled()
    }
    
    func checkAnswer(item: PokemonItem) {
        if item.name == pokemon?.name {
            points += 1
        }
        
        if points >= 5 {
            stopIt()
        } else {
            getPokemon()
        }
    }
    
    func stopIt() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct OffView_Previews: PreviewProvider {
    static var previews: some View {
        OffView()
    }
}
