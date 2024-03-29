import SwiftUI

struct LinkItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var link: String
}

struct ContentView: View {
    @State private var name = ""
    @State private var link = ""
    @State private var links = [LinkItem]()
    @State private var deletedItem: LinkItem? = nil

    var sortedLinks: [LinkItem] {
        return links.sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            TextField("Enter company name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter company's link", text: $link)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save", action: saveLink)
                .padding()
            
            List {
                ForEach(sortedLinks) { item in // Use sortedLinks instead of links
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Button(action: {
                                deleteLink(item)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        if let url = URL(string: item.link) {
                            Link("Visit link", destination: url)
                        } else {
                            Text("Invalid URL: \(item.link)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            if let deletedItem = deletedItem {
                Button("Undo", action: {
                    undoDelete(deletedItem)
                })
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear(perform: loadLinks)
    }
    
    func saveLink() {
        let newLink = LinkItem(name: name, link: link)
        links.append(newLink)
        saveLinks()
        name = ""
        link = ""
    }
    
    func deleteLink(_ item: LinkItem) {
        if let index = links.firstIndex(where: { $0.id == item.id }) {
            deletedItem = links.remove(at: index)
            saveLinks()
        }
    }
    
    func undoDelete(_ item: LinkItem) {
        if let deletedItem = deletedItem {
            links.append(deletedItem)
            saveLinks()
            self.deletedItem = nil
        }
    }
    
    func saveLinks() {
        if let encoded = try? JSONEncoder().encode(links) {
            UserDefaults.standard.set(encoded, forKey: "links")
        }
    }
    
    func loadLinks() {
        if let data = UserDefaults.standard.data(forKey: "links") {
            if let decoded = try? JSONDecoder().decode([LinkItem].self, from: data) {
                links = decoded
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
