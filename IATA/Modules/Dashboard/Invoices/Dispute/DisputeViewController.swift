import UIKit

class DisputeViewController: BaseViewController<DisputeModel, DefaultDisputeState> {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        state = DefaultDisputeState()
        super.viewDidLoad()
        self.tabView.rowHeight = UITableViewAutomaticDimension
        self.tabView.estimatedRowHeight = 200
        loadData()
    }
    
    override func getNavView() -> UIView? {
        return navView
    }
    
    override func getNavBar() -> UINavigationBar? {
        return navBar
    }
    
    override func getNavItem() -> UINavigationItem? {
        return navItem
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DisputeTableViewCell.identifier, for: indexPath) as? DisputeTableViewCell else {
            return UITableViewCell()
        }
        
        guard let model = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.initCell(model: model)
        return cell
    }

    override func loadData() {
        super.loadData()
        self.state?.getDisputeListStringJson()
            //.withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }

    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.invoiceDisputeTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarClose(), color: UIColor.white)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func backButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func registerCells() {
        self.getTableView().register(DisputeTableViewCell.nib, forCellReuseIdentifier: DisputeTableViewCell.identifier)
    }

}
