import Foundation

// MARK: - Extensions

extension JSONEncoder {
  func encode(json: Any) throws -> Data {
    return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }
}

// MARK: - JSONCodingKeys

struct JSONCodingKeys: CodingKey {
  var stringValue: String

  init?(stringValue: String) {
    self.stringValue = stringValue
  }

  var intValue: Int?

  init?(intValue: Int) {
    self.init(stringValue: "\(intValue)")
    self.intValue = intValue
  }
}

// MARK: - UnkeyedDecodingContainer

extension UnkeyedDecodingContainer {
  mutating func decode(_ type: [Any].Type) throws -> [Any] {
    var array: [Any] = []

    while isAtEnd == false {
      if let value = try? decode(Bool.self) {
        array.append(value)
      } else if let value = try? decode(Double.self) {
        array.append(value)
      } else if let value = try? decode(String.self) {
        array.append(value)
      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
        array.append(nestedDictionary)
      } else if let nestedArray = try? decode(Array<Any>.self) {
        array.append(nestedArray)
      }
    }

    return array
  }

  mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
    let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
    return try nestedContainer.decode(type)
  }
}

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
  func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
    let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
    return try container.decode(type)
  }

  func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
    guard contains(key) else {
      return nil
    }
    return try decode(type, forKey: key)
  }

  func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
    var container = try self.nestedUnkeyedContainer(forKey: key)
    return try container.decode(type)
  }

  func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
    guard contains(key) else {
      return nil
    }
    return try decode(type, forKey: key)
  }

  func decode(_ type: [String: Any].Type) throws -> [String: Any] {
    var dictionary = [String: Any]()

    for key in allKeys {
      if let intValue = try? decode(Int.self, forKey: key) {
        dictionary[key.stringValue] = intValue
      } else if let stringValue = try? decode(String.self, forKey: key) {
        dictionary[key.stringValue] = stringValue
      } else if let boolValue = try? decode(Bool.self, forKey: key) {
        dictionary[key.stringValue] = boolValue
      } else if let doubleValue = try? decode(Double.self, forKey: key) {
        dictionary[key.stringValue] = doubleValue
      } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
        dictionary[key.stringValue] = nestedDictionary
      } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
        dictionary[key.stringValue] = nestedArray
      } else if try decodeNil(forKey: key) {
        dictionary[key.stringValue] = true
      }
    }

    return dictionary
  }

  func decodeJsonDictionaryIfPresent(forKey key: KeyedDecodingContainer.Key) -> [String: Any]? {
    if let dictionary = try? decodeIfPresent([String: Any].self, forKey: key) {
      return dictionary
    }

    guard let decodedData = try? decodeIfPresent(Data.self, forKey: key), let data = decodedData else {
      return nil
    }

    do {
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    } catch {
      return nil
    }
  }

  func decodeIfPresent(forKey key: K, kind: String) throws -> ItemCodable? {
    guard let coder = Configuration.shared.coders[kind] else {
      return nil
    }
    return try coder.decode(from: self, forKey: key)
  }
}

// MARK: - KeyedEncodingContainer

extension KeyedEncodingContainer {
  mutating func encode(jsonDictionary: [String: Any], forKey key: K) {
    if let data = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted) {
      try? encodeIfPresent(data, forKey: key)
    }
  }

  mutating func encodeIfPresent(model: ItemCodable?,
                                forKey key: KeyedEncodingContainer.Key,
                                kind: String) throws {
    guard let model = model, let coder = Configuration.shared.coders[kind] else {
      return
    }
    try coder.encode(model: model, forKey: key, container: &self)
  }
}
