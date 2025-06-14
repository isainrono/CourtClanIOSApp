//
//  StatisticsView.swift
//  CourtClan
//
//  Created by Isain Rodriguez Noreña on 5/6/25.
//

import SwiftUI

struct StatisticsView: View {
    
    var wins: Int = 49
    var losses: Int = 5
    var draws: Int = 10
    var totalGames: Int {
        wins + losses + draws
    }
    var winPercentage: Double {
        Double(wins) / Double(totalGames)
    }
    var lossPercentage: Double {
        Double(losses) / Double(totalGames)
    }
    var drawPercentage: Double {
        Double(draws) / Double(totalGames)
    }
    
    init(win: Int, loss: Int, draw: Int){
        self.wins = win
        self.losses = loss
        self.draws = draw
    }
    
    
    var body: some View {
        HStack{
            Text("Stadistics")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
        
        HStack (spacing: 8){
            ZStack {
                // Background Circle
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(maxWidth: 120, maxHeight: 120)
                
                // First color segment (wins)
                Circle()
                    .trim(from: 0, to: winPercentage)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                    .frame(maxWidth: 120, maxHeight: 120)
                    .rotationEffect(.degrees(-90))
                
                // Second color segment (losses)
                Circle()
                    .trim(from: winPercentage, to: winPercentage + lossPercentage)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                    .frame(maxWidth: 120, maxHeight: 120)
                    .rotationEffect(.degrees(-90))
                
                // Third color segment (draws)
                Circle()
                    .trim(from: winPercentage + lossPercentage, to: 1)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 5, dash: [1,0]))
                    .frame(maxWidth: 120, maxHeight: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(totalGames)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("GAMES")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            Spacer() // Pushes the following VStack to the right
            VStack(alignment: .leading) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("Ganados")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer() // Pushes the next element to the right
                    Text(wins.description)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Divider()
                    .frame(height: 0.2)
                    .background(Color.gray)
                
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    Text("Perdidos")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer() // Pushes the next element to the right
                    Text(losses.description)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Divider()
                    .frame(height: 0.2)
                    .background(Color.gray)
                
                HStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                    Text("Empatados")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Spacer() // Pushes the next element to the right
                    Text(draws.description)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(2))
        .background(Color(red: 103/255, green: 65/255, blue: 153/255, opacity: 0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        
    }
}

#Preview {
    let wins: Int = 49
    let losses: Int = 5
    let draws: Int = 10
    StatisticsView(win: wins, loss: losses, draw: draws)
}
