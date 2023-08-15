//
//  ContentView.swift
//  WordScramble
//
//  Created by Eugene on 14/08/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self)  { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
                
                Section {
                    Text("Current score is \(score)")
                }
            }
            .navigationTitle(rootWord)
            .toolbar { // Day 31 Challenge 2
                Button("Start Game", action: startGame)
            }
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
       
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        // Validations
        
        // Word must have at least 3 char - Day 31 challenge 1
        
        guard answer.count > 2 else {
            wordError(title: "Word not long enough", message: "It must have at least 3 letters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not recognised", message: "That is not a real word!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += 1
            score += answer.count
            if answer.count == rootWord.count {
                score += 10 // extra points for anagram
            }
        }
        newWord = ""
        
    }
    
    func startGame() {
        
        // Reset game variables
        score = 0
        usedWords = []
        
        if let startWordsURL = Bundle.main.url(forResource: "start",  withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                // loaded file!
                
                // Split into array
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm" // allwords is an optional so need to provide default
                
                return
            }
            
            fatalError("Could not load start.txt from bundle.")
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
