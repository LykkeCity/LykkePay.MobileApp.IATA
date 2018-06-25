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

    private func loadData() {
        self.state?.getDisputeListStringJson()
            .withSpinner(in: view)
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
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.invoiceDisputeTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        
        let buttonImage = R.image.backIcon()?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 10)
        
        return UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(backButtonAction))
    }
    
    @objc func backButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func registerCells() {
        self.getTableView().register(DisputeTableViewCell.nib, forCellReuseIdentifier: DisputeTableViewCell.identifier)
    }

}
