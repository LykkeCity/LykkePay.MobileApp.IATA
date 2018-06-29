import Foundation
import UIKit
import ObjectMapper

class BaseViewController<T: Mappable, S: DefaultBaseState<T>>:
    BaseNavController,
    UITableViewDelegate,
    UITableViewDataSource {
    
    var state: S?
    
    let refreshControl = UIRefreshControl()
   
    override func setUp() {
        self.addRefreshControl()
        self.registerCells()
        self.getTableView().delegate = self
        self.getTableView().dataSource = self
        self.getTableView().tableFooterView = UIView()
        self.getTableView().showsVerticalScrollIndicator = false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.state?.getItems().count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc func refresh() {
        loadData()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadData() {
        self.beginRefreshing()
    }
    
    func beginRefreshing() {
        var offset = self.getTableView().contentOffset
        offset.y = -81
        self.refreshControl.beginRefreshing()
        self.getTableView().contentOffset = offset
    }
    
    private func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string:  R.string.localizable.commonLoadingMessage())
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        getTableView().addSubview(refreshControl)
    }
}
