import Cocoa

/// Notification name that will be sent when all the diagnoses are loaded
let DiagnosisStoreDiagnosesLoadedNotification = "com.kivi.ihcapp.DiagnosisStoreDiagnosesLoadedNotification"

class DiagnosisStore: NSObject {
    /// Adapter used to make API calls
    var adapter: DiagnosisAPIAdapter
    
    // MARK: Singleton
    
    /// One and only instance of the Type stored as shared instance
    static let sharedInstance = DiagnosisStore()
    
    /// Private initializer to prevent multiple instances
    private override init() {
        adapter = DiagnosisAPIAdapter(parser: DiagnosisJSONParser())
        
        super.init()
    }
    
    // MARK: -  Stored properties
    private var diagnoses: [Int: [Diagnosis]] = [:]
    
    private var notificationCenter = NSNotificationCenter.defaultCenter()
    
    var selectedCategory: Category? {
        didSet {
            diagnosesUnderSelectedCategory = diagnosesUnderCategory(selectedCategory)
        }
    }
    
    // MARK: - Computed properties
    var diagnosesUnderSelectedCategory: [Diagnosis] = []
    
    // MARK: - Methods
    
    /**
        Loads all the diagnoses from server and posts a notification when done
     */
    func loadAllDiagnoses() {
        diagnoses.removeAll()
        notificationCenter.postNotificationName(DiagnosisStoreDiagnosesLoadedNotification, object: self)
        
        adapter.getAll {
            result in
            switch result {
            case let .Success(diagnoses):
                for diagnosis in diagnoses {
                    let categoryId = diagnosis.categoryId
                    if self.diagnoses[categoryId] == nil {
                        self.diagnoses[categoryId] = []
                    }
                    self.diagnoses[categoryId]!.append(diagnosis)
                }
            case let .Failure(error):
                print("Got error: \(error)")
            }
            self.notificationCenter.postNotificationName(DiagnosisStoreDiagnosesLoadedNotification, object: self)
        }
    }
    
    // MARK: - Helpers
    private func diagnosesUnderCategory(cat: Category?) -> [Diagnosis] {
        guard let category = cat else {
            return []
        }
        
        guard category.hasSubcategories else {
            guard let diagnoses = diagnoses[category.id!] else {
                return []
            }
            return diagnoses
        }
        
        var categoryIds = [Int]()
        func getSubcategoriesIdForCategory(category: Category, inout categoryIds: [Int]) {
            
            categoryIds.append(category.id!)
            for subcategory in category.subcategories {
                getSubcategoriesIdForCategory(subcategory, categoryIds: &categoryIds)
            }
        }
        
        getSubcategoriesIdForCategory(category, categoryIds: &categoryIds)
        
        var retDiagnoses = [Diagnosis]()
        for categoryId in categoryIds {
            if let diagnoses = diagnoses[categoryId] {
                retDiagnoses.appendContentsOf(diagnoses)
            }
        }
        return retDiagnoses

    }
}
