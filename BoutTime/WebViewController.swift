//
//  WebViewController.swift
//  BoutTime
//
//  Created by nikko444 on 2019-02-18.
//  Copyright © 2019 nikko444. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var factCaption = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: factToURL(parse: factCaption))
        webView.load(request)
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func factToURL (parse fact: String) -> URL { //formating a fact to work as a web link.
        let replaced = fact.replacingOccurrences(of: "[!@#$%&*(){} \\[\\]\"^<>.,:;']", with: "+", options: .regularExpression, range: nil).lowercased()
        let step1 = "https://en.wikipedia.org/w/index.php?search=" + replaced
        let step2 = step1 + "&title=Special:Search&go=Go"
        let url = URL(string: step2)
        return url!
    }
}
