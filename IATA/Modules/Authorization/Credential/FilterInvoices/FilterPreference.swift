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
    
    internal func getChecked(id: String!, type: InvoiceViewModelItemType) -> Bool {
        switch type {
        case .billingCategories:
            let billingCategories = getBillingChecked()
            return (billingCategories?.contains(id))!
        case .currencies:
            let currencies = getCurrency()
            return (currencies?.contains(id))!
        case .settlementPeriod:
            let settlementPeriods = getSettlementPeriod()
            return (settlementPeriods?.contains(id))!
        case .airlines:
            let airlines = getAirlines()
            return (airlines?.contains(id))!
        default:
            return false
        }
    }
    
    internal func setChecked(type: InvoiceViewModelItemType, isChecked: Bool, id: String) {
        switch type {
        case .currencies:
            var list = getCurrency()
            setUpChecked(isChecked: isChecked, list: &list, id: id)
            saveCurrency(list)
            break
        case .billingCategories:
            var list = getBillingChecked()
            setUpChecked(isChecked: isChecked, list: &list, id: id)
            saveBillingCategory(list)
            break
        case .settlementPeriod:
            var list = getSettlementPeriod()
            setUpChecked(isChecked: isChecked, list: &list, id: id)
            saveSettlementPeriod(list)
            break
        case .airlines:
            var list = getAirlines()
            setUpChecked(isChecked: isChecked, list: &list, id: id)
            saveAirlines(list)
        default:
            break
        }
    }
    
    private func setUpChecked(isChecked: Bool, list: inout [String]?, id: String) {
        if (isChecked && list?.index(where: {$0 == id}) == nil) {
            list?.append(id)
        } else if !isChecked, let index = list?.index(where: {$0 == id}) {
            list?.remove(at: index)
        }
    }
}

