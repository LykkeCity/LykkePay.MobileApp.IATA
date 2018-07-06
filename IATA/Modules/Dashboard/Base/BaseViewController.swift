import Foundation
import UIKit
import ObjectMapper

class BaseViewController<T: Mappable, S: DefaultBaseState<T>>:
    BaseNavController,
    UITableViewDelegate,
    UITableViewDataSource {
    
    var state: S?
    
    /// Refresh state
    var isRefreshing = false
    
    /// Refresh controll update funcion. Set to enable pull to refresh
    var refreshControllUpdateFunction: (() -> ())?
    
    let refreshControl = UIRefreshControl()
   
    override func setUp() {
        self.addRefreshControl()
        self.registerCells()
        self.getTableView().delegate = self
        self.getTableView().dataSource = self
        self.getTableView().tableFooterView = UIView()
        self.getTableView().showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        superviewWillApper()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        superviewDidDisappear()
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadData() {
        self.beginRefreshing()
    }
    
    /// Call on viewWillApper
    func superviewWillApper(){
        if isRefreshing && !refreshControl.isRefreshing{
            beginRefreshing()
        }
    }
    
    /// Call on viewDidDisapper
    func superviewDidDisappear(){
        endRefreshAnimation(wasEmpty: false, dataFetched: !isRefreshing)
    }
    
    /// Presents animating UIRefreshControll
    func beginRefreshing(){
        refreshControl.beginRefreshing()
        let contentOffset = CGPoint(x: 0, y: -refreshControl.bounds.size.height)
        getTableView().setContentOffset(contentOffset, animated: true)
        isRefreshing = true
    }
    
    /// Hides UIRefreshControll and saves state of refresh
    func endRefreshAnimation(wasEmpty: Bool, dataFetched: Bool){
        refreshControl.endRefreshing()
        
        isRefreshing = !dataFetched
        
        if !wasEmpty{
            getTableView().setContentOffset(.zero, animated: true)
        }else{
            getTableView().setContentOffset(.zero, animated: false)
        }
    }
    
    private func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string:  R.string.localizable.commonLoadingMessage())
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        getTableView().addSubview(refreshControl)
    }
}
