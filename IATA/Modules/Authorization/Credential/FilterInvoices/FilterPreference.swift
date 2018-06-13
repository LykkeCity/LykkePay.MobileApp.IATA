import Foundation

class FilterPreference {
    
    private enum PropertyKey: String {
        case minValue
        case maxValue
        case status
        case airlines
        case billingCategories
        case currencies
        case settlementPeriod
    }
    
    static internal let shared = FilterPreference()
    static let preferences = UserDefaults.standard
    
    private init() {
    }
    
    internal func saveIndexOfStatus(_ indexOfStatus: Int!) {
        UserPreference.preferences.set(indexOfStatus, forKey: PropertyKey.status.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getIndexOfStatus() -> Int! {
        return UserPreference.preferences.integer(forKey: PropertyKey.status.rawValue)

    }
    
    internal func saveBillingCategory(_ arrayBilling: [String]?) {
        UserPreference.preferences.set(arrayBilling, forKey: PropertyKey.billingCategories.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getBillingChecked() -> [String]? {
        if let values =  UserPreference.preferences.array(forKey: PropertyKey.billingCategories.rawValue) as? [String] {
            return values
        }
       return [String]()
    }
    
    internal func getAirlines() -> [String]? {
        if let values =  UserPreference.preferences.array(forKey: PropertyKey.airlines.rawValue) as? [String] {
            return values
        }
        return [String]()
    }
    
    internal func saveAirlines(_ arrayBilling: [String]?) {
        UserPreference.preferences.set(arrayBilling, forKey: PropertyKey.airlines.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getCurrency() -> [String]? {
        if let values =  UserPreference.preferences.array(forKey: PropertyKey.currencies.rawValue) as? [String] {
            return values
        }
        return [String]()
    }
    
    internal func saveCurrency(_ arrayBilling: [String]?) {
        UserPreference.preferences.set(arrayBilling, forKey: PropertyKey.currencies.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getSettlementPeriod() -> [String]? {
        if let values =  UserPreference.preferences.array(forKey: PropertyKey.settlementPeriod.rawValue) as? [String] {
            return values
        }
        return [String]()
    }
    
    internal func saveSettlementPeriod(_ arrayBilling: [String]?) {
        UserPreference.preferences.set(arrayBilling, forKey: PropertyKey.settlementPeriod.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func saveMinValue(_ minValue: Int?) {
        UserPreference.preferences.set(minValue, forKey: PropertyKey.minValue.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getMinValue() -> Int? {
        return UserPreference.preferences.integer(forKey: PropertyKey.minValue.rawValue)
    }
    
    internal func saveMaxValue(_ maxValue: Int?) {
        UserPreference.preferences.set(maxValue, forKey: PropertyKey.maxValue.rawValue)
        let didSave = UserPreference.preferences.synchronize()
        
        if !didSave {
            
        }
    }
    
    internal func getMaxValue() -> Int? {
        return UserPreference.preferences.integer(forKey: PropertyKey.maxValue.rawValue)
    }
    
    internal func getChecked(name: String!, type: InvoiceViewModelItemType) -> Bool {
        switch type {
        case .billingCategories:
            let billingCategories = getBillingChecked()
            return (billingCategories?.contains(name))!
        case .currencies:
            let currencies = getCurrency()
            return (currencies?.contains(name))!
        case .settlementPeriod:
            let settlementPeriods = getSettlementPeriod()
            return (settlementPeriods?.contains(name))!
        case .airlines:
            let airlines = getAirlines()
            return (airlines?.contains(name))!
        default:
            return false
        }
    }
    
    internal func setChecked(type: InvoiceViewModelItemType, isChecked: Bool, name: String) {
        switch type {
        case .currencies:
            var currencies = getCurrency()
            if (isChecked) {
                currencies?.append(name)
            } else if let index = currencies?.index(where: {$0 == name}) {
                currencies!.remove(at: index)
            }
            saveCurrency(currencies)
            break
        case .billingCategories:
            var billingCategories = getBillingChecked()
            if (isChecked) {
                billingCategories?.append(name)
            } else if let index = billingCategories?.index(where: {$0 == name}) {
                billingCategories!.remove(at: index)
            }
            saveBillingCategory(billingCategories)
            break
        case .settlementPeriod:
            var settlementPeriod = getSettlementPeriod()
            if (isChecked) {
                settlementPeriod?.append(name)
            } else if let index = settlementPeriod?.index(where: {$0 == name}) {
                settlementPeriod!.remove(at: index)
            }
            saveSettlementPeriod(settlementPeriod)
            break
        case .airlines:
            var airlines = getAirlines()
            if (isChecked) {
                airlines?.append(name)
            } else if let index = airlines?.index(where: {$0 == name}) {
                airlines!.remove(at: index)
            }
            saveAirlines(airlines)
        default:
            break
        }
    }
}

