import UIKit

class InvoiceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tabView: UITableView!
    let items = ["Most Popular", "Latest", "Trending", "Nearest", "Top Picks"]
    var usersArray : Array = [["first_name": "michael", "last_name": "jackson"], ["first_name" : "bill", "last_name" : "gates"], ["first_name" : "steve", "last_name" : "jobs"], ["first_name" : "mark", "last_name" : "zuckerberg"], ["first_name" : "anthony", "last_name" : "quinn"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuView = BTNavigationDropdownMenu(title: BTTitle.index(1), items: items)
        self.navigationItem.titleView = menuView
        let nib = UINib.init(nibName: "InvoiceTableViewCell", bundle: nil)
        self.tabView.register(nib, forCellReuseIdentifier: "InvoiceTableViewCell")
        self.tabView.delegate = self
        self.tabView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceTableViewCell", for: indexPath) as! InvoiceTableViewCell
        
        let dict = usersArray[indexPath.row]
        
        
        return cell
    }
}
