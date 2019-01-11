# BitcoinKit-iOS

Bitcoin and BitcoinCash(ABC) SPV wallet toolkit for Swift. This is a full implementation of SPV node including wallet creation/restore, syncronzation with network, send/receive transactions, and more.


## Features

- Full SPV implementation for fast mobile performance
- Send/Receive Legacy transactions (*P2PKH*, *P2PK*, *P2SH*)
- Send/Receive Segwit transactions (*P2WPKH*)
- Send/Receive Segwit transactions compatible with legacy wallets (*P2WPKH-SH*)
- Fee calculation depending on wether sender pays the fee or receiver
- Encoding/Decoding of base58, bech32, cashaddr addresses
- [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) hierarchical deterministic wallets implementation.
- [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) mnemonic code for generating deterministic keys.
- [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) multi-account hierarchy for deterministic wallets.
- [BIP21](https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki) URI schemes, which include payment address, amount, label and other params
- Real-time fee rates



## Usage

### Initialization

`BitcoinKit` requires you to provide mnemonic phrase when it is initialized:

```swift
let words = ["word1", ... , "word12"]
```

#### Bitcoin

```swift
let bitcoinKit = BitcoinKit(withWords: words, coin: .bitcoin(network: .testNet), minLogLevel: .verbose)
```

#### Bitcoin Cash

```swift
let bitcoinCashKit = BitcoinKit(withWords: words, coin: .bitcoinCash(network: .testNet), minLogLevel: .verbose)
```

Both networks can be configured to work in `mainNet` or `testNet`.

##### Additional parameters:
- `confirmationsThreshold`: Minimum number of confirmations required for an unspent output in incoming transaction to be spent (*default: 6*)
- `minLogLevel`: Can be configured for debug purposes if required.

### Starting and Stopping

`BitcoinKit` requires to be started with `start` command, but does not need to be stopped. It will be in synced state as long as it is possible:

```swift
try bitcoinKit.start()
```

#### Clearing data from device

`BitcoinKit` uses internal database for storing data fetched from blockchain. `clear` command can be used to stop and clean all stored data:

```swift
try bitcoinKit.clear()
```


### Getting wallet data

`BitcoinKit` holds all kinds of data obtained from and needed for working with blockchain network

#### Current Balance

Balance is provided in `Satoshi`:

```swift
bitcoinKit.balance

// 2937096768
```

#### Last Block Info

Last block info contains `headerHash`, `height` and `timestamp` that can be used for displaying sync info to user:

```swift
bitcoinKit.lastBlockInfo 

// ▿ Optional<BlockInfo>
//  ▿ some : BlockInfo
//    - headerHash : //"00000000000041ae2164b486398415cca902a41214cad72291ee04b212bed4c4"
//    - height : 1446751
//    ▿ timestamp : Optional<Int>
//      - some : 1544097931
```

#### Receive Address

Get an address which you can receive coins to. Receive address is changed each time after you actually get a transaction in which you receive coins to that address

```swift
bitcoinKit.receiveAddress

// "mgv1KTzGZby57K5EngZVaPdPtphPmEWjiS"
```

#### Transactions

You can get all your transactions as follows:

```swift
bitcoinKit.transactions

// ▿ 2 elements
//   ▿ 0 : TransactionInfo
//     - transactionHash : "0f83c9b330f936dc4a2458b7d3bb06dce6647a521bf6d98f9c9d3cdd5f6d2a73"
//     ▿ from : 2 elements
//       ▿ 0 : TransactionAddressInfo
//         - address : "mft8jpnf3XwwqhaYSYMSXePFN85mGU4oBd"
//         - mine : true
//       ▿ 1 : TransactionAddressInfo
//         - address : "mnNS5LEQDnYC2xqT12MnQmcuSvhfpem8gt"
//         - mine : true
//     ▿ to : 2 elements
//       ▿ 0 : TransactionAddressInfo
//         - address : "n43efNftHQ1cXYMZK4Dc53wgR6XgzZHGjs"
//         - mine : false
//       ▿ 1 : TransactionAddressInfo
//         - address : "mrjQyzbX9SiJxRC2mQhT4LvxFEmt9KEeRY"
//         - mine : true
//     - amount : -800378
//     ▿ blockHeight : Optional<Int>
//       - some : 1446602
//    ▿ timestamp : Optional<Int>
//       - some : 1543995972
//   ▿ 1 : TransactionInfo
//  ...
```

### Creating new transaction

In order to create new transaction, call `send(to: String, value: Int)` method on `BitcoinKit`

```swift
try bitcoinKit.send(to: "mrjQyzbX9SiJxRC2mQhT4LvxFEmt9KEeRY", value: 1000000)
```

This first validates a given address and amount, creates new transaction, then sends it over the peers network. If there's any error with given address/amount or network, it raises an exception.

#### Validating transaction before send

One can validate address and fee by using following methods:

```swift
try bitcoinKit.validate(address: "mrjQyzbX9SiJxRC2mQhT4LvxFEmt9KEeRY")
try bitcoinKit.fee(for: 1000000, toAddress: "mrjQyzbX9SiJxRC2mQhT4LvxFEmt9KEeRY", senderPay: true)
```
`senderPay` parameter defines who pays the fee

### Parsing BIP21 URI

You can use `parse` method to parse a BIP21 URI:

```swift
bitcoinKit.parse(paymentAddress: "bitcoin:175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz")

// ▿ BitcoinPaymentData
//   - address : "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W"
//   - version : nil
//   ▿ amount : Optional<Double>
//     - some : 50.0
//   ▿ label : Optional<String>
//     - some : "Luke-Jr"
//   ▿ message : Optional<String>
//     - some : "Donation for project xyz"
//   - parameters : nil

```

### Subscribing to BitcoinKit data

`BitcoinKit` provides with data like transactions, blocks, balance, kits state in real-time. `BitcoinKitDelegate` protocol must be implemented and set to `BitcoinKit` instance to receive that data.

```swift
class Manager {

	init(words: [String]) {
		bitcoinKit = BitcoinKit(withWords: words, coin: .bitcoin(network: .mainNet)
        bitcoinKit.delegate = self
    }

}

extension Manager: BitcoinKitDelegate {

    public func transactionsUpdated(bitcoinKit: BitcoinKit, inserted: [TransactionInfo], updated: [TransactionInfo], deleted: [Int]) {
		// do something with transactions
    }

    public func balanceUpdated(bitcoinKit: BitcoinKit, balance: Int) {
		// do something with balance
    }

    public func lastBlockInfoUpdated(bitcoinKit: BitcoinKit, lastBlockInfo: BlockInfo) {
		// do something with lastBlockInfo
    }

    public func kitStateUpdated(state: BitcoinKit.KitState) {
		// BitcoinKit.KitState can be one of 3 following states:
		// .synced
		// .syncing(progress: Double)
		// .notSynced
		// 
		// These states can be used to implement progress bar, etc
    }

}
```

## Prerequisites

* Xcode 10.0+
* Swift 4.1+
* iOS 11+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.5.0+ is required to build BitcoinKit.

To integrate HSBitcoinKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
	pod 'HSBitcoinKit'
end
```

Then, run the following command:
```bash
$ pod install
```


## Example Project

All features of the library are used in example project. It can be referred as a starting point for usage of the library.

* [Example Project](https://github.com/horizontalsystems/bitcoin-kit-ios/tree/master/HSBitcoinKitDemo)

## Dependencies

* [HSHDWalletKit](https://github.com/horizontalsystems/hd-wallet-kit-ios) - HD Wallet related features, mnemonic phrase geneartion.
* [HSCryptoKit](https://github.com/horizontalsystems/crypto-kit-ios) - Crypto functions required for working with blockchain.

## License

The `HSBitcoinKit` toolkit is open source and available under the terms of the [MIT License](https://github.com/horizontalsystems/bitcoin-kit-ios/blob/master/LICENSE).

