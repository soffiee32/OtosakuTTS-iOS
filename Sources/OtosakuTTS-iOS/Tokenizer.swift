//
//  Tokenizer.swift
//  OtosakuTTS-iOS
//


import Foundation

public final class Tokenizer {
    // MARK: ––– Public Interface
    public init(tokensFile: URL, dictFile: URL) throws {
        self.tokenToId = try Tokenizer.loadTokens(tokensFile)
        self.idSpace   = tokenToId[" "]            // space
        self.idOOV     = tokenToId["<oov>"]        // unknown
        self.phonemeDB = try Tokenizer.loadDict(dictFile)
    }
    
    /// Encode string → array of indices
    public func encode(_ text: String) -> [Int] {
        var ids: [Int] = []
        // Replace CRLF/tabs with space and split by regex:
        let cleaned = text.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        let pattern = #"([A-Za-z]+|[0-9]+|[^A-Za-z0-9\s])|\s+"#    // word|digits|punctuation|space
        let regex   = try! NSRegularExpression(pattern: pattern)
        for m in regex.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)) {
            let token = String(cleaned[Range(m.range, in: cleaned)!])
            
            if token.trimmingCharacters(in: .whitespaces).isEmpty {          // space
                append(" ", to: &ids);          continue
            }
            if tokenToId[token] != nil {                                     // punctuation
                append(token, to: &ids);       continue
            }
            // ----- word / number -----
            let w = token.lowercased()
            if let prons = phonemeDB[w], let first = prons.first {           // exists in dictionary
                for ph in first { append(ph, to: &ids) }
            } else {                                                         // fallback by characters
                for ch in w { append(String(ch), to: &ids) }
            }
        }
        // remove trailing spaces
        while ids.last == idSpace { _ = ids.popLast() }
        return ids
    }
    
    // MARK: ––– Private Part
    
    private let tokenToId: [String:Int]          // "token → id"
    private let phonemeDB: [String:[[String]]]   // JSON dictionary
    private let idSpace: Int?                    // space index
    private let idOOV:   Int?                    // <oov> index
    
    private func append(_ tok: String, to arr: inout [Int]) {
        if let id = tokenToId[tok]        { arr.append(id) }
        else if let id = idOOV            { arr.append(id) }
        // otherwise ignore character
    }
    
    private static func loadTokens(_ url: URL) throws -> [String:Int] {
        let lines: [String]
        do {
            lines = try String(contentsOf: url)
                .components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
        } catch {
            throw OtosakuTTSError.invalidTokensFile
        }
        var map = [String:Int]()
        for (i,t) in lines.enumerated() { map[t] = i }
        return map
    }
    private static func loadDict(_ url: URL) throws -> [String:[[String]]] {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw OtosakuTTSError.invalidDictionaryFile
        }
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String:[[String]]] else {
            throw OtosakuTTSError.invalidDictionaryFile
        }
        return obj
    }
}
