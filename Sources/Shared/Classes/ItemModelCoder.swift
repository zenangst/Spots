import Foundation

// MARK: - Protocol

protocol AnyItemModelCoder {
  func encode<T: KeyedEncodingContainerProtocol>(model: ItemCodable,
                                                 forKey key: T.Key,
                                                 container: inout T) throws
  func decode<T: KeyedDecodingContainerProtocol>(from container: T,
                                                 forKey key: T.Key) throws -> ItemCodable?
}

// MARK: - Class

public class ItemModelCoder<T: View, U: ItemModel>: AnyItemModelCoder {
  func encode<T: KeyedEncodingContainerProtocol>(model: ItemCodable,
                                                 forKey key: T.Key,
                                                 container: inout T) throws {
    try container.encodeIfPresent(model as? U, forKey: key)
  }

  func decode<T: KeyedDecodingContainerProtocol>(from container: T,
                                                 forKey key: T.Key) throws -> ItemCodable? {
    return try container.decodeIfPresent(U.self, forKey: key)
  }
}
