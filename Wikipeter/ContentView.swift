//
//  ContentView.swift
//  Wikipeter
//
//  Created by Adrian Böhme on 28.04.20.
//  Copyright © 2020 Adrian Böhme. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var lm = LocationManager()
    @State var settingsOpen: Bool = false
    @State var results: [Result] = []
    @State var pickerSelection = 0

    @State var showingAlert = false;
    @State var errorMessage = ""

    // map stuff
    @State var actionState: Int? = 0
    @State var articleResult:  Result?

    init() {
        UITableView.appearance().tableFooterView = UIView()
        //UITableView.appearance().separatorStyle = .none
        actionState = 0
    }

    func loadArticle(_ articleResult: Result) {
        self.articleResult = articleResult
        self.actionState = 1
    }

    func loadSurroundingArticles() {
        DispatchQueue.main.async {
            let nearby = WikipediaFetcher().getArticlesNearby(latitude: self.lm.location?.latitude ?? 0, longitude: self.lm.location?.longitude ?? 0) { results, error in
                if (error != nil) {
                    self.errorMessage = error!;
                    self.showingAlert = true;
                    return
                }
                self.results = results
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ArticleView(articleResult: $articleResult, articleResults: results), tag: 1, selection: $actionState) { Button("") { } }.frame(width: 0, height: 0, alignment: .top)
                List {


                    Picker("Options", selection: $pickerSelection) {
                        Text("Near you").tag(0)
                        Text("Map view").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())


                    if (pickerSelection == 0) {
                        ForEach(results) { result in
                            SearchResultRow(result: result, loadArticle: self.loadArticle)
                        }
                    } else {
                        VStack {
                            VStack {
                                MapView(results: $results,
                                    loadArticle: loadArticle)
                            }.frame(width: nil, height: 540, alignment: .top).cornerRadius(10)
                        }
                        HStack {
                            Spacer()
                            Text(lm.placemark?.name ?? "Searching location...").font(.footnote)
                            Spacer()
                        }
                    }
                } }
                .navigationBarTitle("🥕 Wikipeter")
                .navigationBarItems(trailing:
                        Button(action: loadSurroundingArticles) {
                            Image(systemName: "arrow.clockwise")
                        }.font(Font.system(size: 23)))
        }.onAppear(perform: loadSurroundingArticles)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Alright")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
