

import UIKit

class ViewController: UIViewController {

    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var pageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        pageControl.numberOfPages = 10 
        pageControl.currentPage = 0
        pageLabel.text = "\(pageControl.currentPage + 1)"
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
     
    @IBAction func pageChange(_ sender: UIPageControl) {
        pageLabel.text = "\(sender.currentPage + 1)"
    }
}
