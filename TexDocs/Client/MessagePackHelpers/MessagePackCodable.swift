//
//  MessagePackCodable.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation
import MessagePack


protocol MessagePackEncodable {
    var values: [MessagePackValuePrimitive] { get }
}

protocol MessagePackDecodable {
    init(from values: [MessagePackValue]) throws
}

protocol MessagePackCodable: MessagePackEncodable, MessagePackDecodable {}

extension MessagePackEncodable {
    func encode() -> Data {
        return pack(.array(values.map { $0.messagePackValue }))
    }
}

extension MessagePackDecodable {
    init(decode packedData: Data) throws {
        try self.init(from: (unpackAll(packedData).first?.arrayValue).unwrap())
    }
}

enum MessagePackError: Error {
    case unwrapFailed
    case arrayIndexDoesNotExists
}

extension Optional {
    func unwrap() throws -> Wrapped {
        guard let wrapped = self else {
            throw MessagePackError.unwrapFailed
        }
        return wrapped
    }
}

extension MessagePackValue {
    var uuidValue: UUID? {
        guard let uuidString = stringValue else { return nil }

        return UUID(uuidString: uuidString)
    }
}

extension Array where Element == MessagePackValue {
    func at(_ index: Int) throws -> MessagePackValue {
        guard count > index else {
            throw MessagePackError.arrayIndexDoesNotExists
        }
        return self[index]
    }
}
