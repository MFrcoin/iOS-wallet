//
//  BitcoinUnsignedTransaction.swift
//  MFCoin
//
//  Created by Admin on 03.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation

public struct BitcoinUnsignedTransaction {
    public let tx: BitcoinTransaction
    public let utxos: [BitcoinUnspentTransaction]
    
    public init(tx: BitcoinTransaction, utxos: [BitcoinUnspentTransaction]) {
        self.tx = tx
        self.utxos = utxos
    }
}
