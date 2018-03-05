//
//  WebViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/24.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    var spinner = UIActivityIndicatorView()
    
    var targetURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        webView.navigationDelegate = self
        
//         Activity Indicators
        spinner.activityIndicatorViewStyle = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            spinner.startAnimating()
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}
