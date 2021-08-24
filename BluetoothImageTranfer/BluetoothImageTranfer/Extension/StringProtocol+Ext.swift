//
//  StringProtocol+Ext.swift
//  StringProtocol+Ext
//
//  Created by limefriends on 2021/08/20.
//

import Foundation

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            let binary = self[startIndex..<endIndex]
            return UInt8(binary, radix: 16)
        }
    }
}
