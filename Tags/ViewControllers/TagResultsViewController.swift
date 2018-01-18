//
//  TagResultsViewController.swift
//  H#
//
//  Created by brianna on 1/10/18.
//  Copyright © 2018 brianna. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class TagResultsViewController: UIViewController {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    public var unsafeTag: String?
    public var shouldShowBullets: Bool!
    
    private var tags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tag = unsafeTag {
            scrapeHTML(from: tag)
            title = "#" + tag
        }
    }
    
    private func scrapeHTML(from tag: String) {
        let path = "https://top-hashtags.com/hashtag/\(tag)/"
        if let url = URL(string: path) {
            Alamofire.request(url).responseString() { response in
                guard
                    response.result.isSuccess,
                    let html = response.result.value
                    else {
                        print("Failed to scrape HTML")
                        return
                }
                
                print("Scraped HTML Successfully")
                
                self.parse(html)
            }
        }
    }
    
    private func parse(_ html: String) {
        guard let doc = try? Kanna.HTML(html: html, encoding: .utf8) else {
            print("Failed to parse HTML")
            return
        }
        
//        print(html)
        
        for i in 1...20 {
            for tagCollection in doc.css("#clip-tags-\(i)") {
                guard
                    let tagsString = tagCollection.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    else {
                        print("Could not trim characters or tagsString is Nil")
                        return
                }
                
                tags.append(tagsString)
            }
        }
        if tags.isEmpty {
            let alert = UIAlertController(title: "That didn't work", message: "Looks like the website didn't like that one. Please try a different tag.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .destructive, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        } else {
            resultsTableView.reloadData()
        }
    }
    
}

extension TagResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        let tagCollection = tags[indexPath.row]
        let bullets = ".\n.\n.\n"
        cell.textLabel?.text = shouldShowBullets ? bullets + tagCollection : tagCollection
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // MARK: - Add tags to clipboard
        let tagCollection = tags[indexPath.row]
        let bullets = "\n.\n.\n.\n"
        UIPasteboard.general.string = shouldShowBullets ? bullets + tagCollection : tagCollection
        let alert = UIAlertController(title: "Copied!", message: "These tags are now on your clipboard!", preferredStyle: .alert)
        let gotIt = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(gotIt)
        present(alert, animated: true, completion: nil)
    }
}
