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
        addRefreshControl()
        self.registerCells()
        self.getTableView().delegate = self
        self.getTableView().dataSource = self
        self.getTableView().tableFooterView = UIView()
        self.getTableView().showsVerticalScrollIndicator = false
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

    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @objc func refresh() {
        loadData()
    }
    
    func loadData() {
        var offset = self.getTableView().contentOffset
        offset.y = -81
        self.refreshControl.endRefreshing()
        self.refreshControl.beginRefreshing()
        self.getTableView().contentOffset = offset
    }
    
    private func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        getTableView().addSubview(refreshControl)
    }
}
