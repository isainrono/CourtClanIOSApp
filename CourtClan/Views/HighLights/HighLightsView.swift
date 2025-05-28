import SwiftUI

// MARK: - 1. Estructura de Datos para el Elemento de la Lista (Sin cambios)

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let hometown: String
}

// MARK: - 2. Vista de Detalle (PersonDetailView) (Sin cambios, ya está perfecta)

struct PersonDetailView: View {

   
    let person: Person
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // PersonDetailView con su propia NavigationView para tener título y botón "Cerrar"
        
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.purple)
                        .padding()

                    Text(person.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("De: \(person.hometown)")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalle de \(person.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - 3. HighLightsView (Tu vista principal de la lista) - ¡ÚNICO CAMBIO AQUÍ!

struct HighLightsView: View {
    // Retain your hardcoded people array if you still need it for the button actions
    // However, if the goal is to show players from the ViewModel, you'd eventually remove this.
    let people: [Person] = [
        Person(name: "Isain Rodríguez", hometown: "Medellín"),
        Person(name: "María Pérez", hometown: "Barcelona"),
        Person(name: "Juan García", hometown: "Madrid"),
        Person(name: "Laura Gómez", hometown: "Buenos Aires")
    ]

    @State private var selectedPerson: Person? // For the existing button and fullScreenCover
    @StateObject var viewModel = PlayersViewModel() // Your ViewModel

    var body: some View {
        NavigationView {
            List {
                // If you want to show the 'people' array from here
                ForEach(people) { person in
                    Button(action: {
                        print("✅ Botón TOCADO para: \(person.name)")
                        self.selectedPerson = person
                        print("selectedPerson set to: \(self.selectedPerson?.name ?? "NIL")")
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                            Text(person.name)
                            Spacer()
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                // If you also want to display players from the ViewModel in the same list:
                // (You'd need to adapt PlayerRowView if you want to use it here,
                // or ensure your Person struct is compatible with Player data.)
                // ForEach(viewModel.filteredPlayers) { player in
                //     PlayerRowView(player: player)
                // }
            }
            // REMOVE this line from here:
            // .navigationTitle("Nombres \(self.viewModel.players.count)")
            .toolbar {
                // Add this ToolbarItem to display the dynamic title
                ToolbarItem(placement: .principal) {
                    Text("Nombres (\(self.viewModel.players.count))") // This will now update reliably
                        .font(.headline) // Or whatever font you prefer for the title
                }
            }
            .fullScreenCover(item: $selectedPerson) { personInCover in
                PersonDetailView(person: personInCover) // Assuming this view takes a Person
            }
            // It's a good idea to fetch data when the view first appears
            // if you intend for the ViewModel's players count to be meaningful.
            .task {
                await viewModel.fetchAllPlayers()
            }
        }
    }
}
#Preview {
    HighLightsView()
}
