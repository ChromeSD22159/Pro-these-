//
//  PurchaseManager.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 20.06.23.
//

import Foundation
import StoreKit
import SwiftUI
import WidgetKit

@MainActor
class PurchaseManager: NSObject, ObservableObject {
    private let entitlementManager: EntitlementManager
    
    private let productIds = ["102", "103", "7777"]//["0000", "1000", "9999", "9990"]

    private var updates: Task<Void, Never>? = nil
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
       
        super.init()
        updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        updates?.cancel()
    }
    
    @Published
    private(set) var products: [Product] = []
    private var productsLoaded = false
    
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified(_, _)):
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
    
    
    
    
    ///
    ///
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    @AppStorage("hasProduct", store: UserDefaults(suiteName: "group.FK.Pro-these-")) var hasProduct: String = ""
    
    var hasUnlockedPro: Bool {
       return !self.purchasedProductIDs.isEmpty
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                hasProduct = transaction.productID
                self.purchasedProductIDs.insert(transaction.productID)
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                hasProduct = ""
                self.purchasedProductIDs.remove(transaction.productID)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        
        self.entitlementManager.hasPro = !self.purchasedProductIDs.isEmpty
    }
}


extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}


class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.FK.Pro-these-")!

    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
