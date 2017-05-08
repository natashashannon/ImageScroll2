import UIKit

struct Item {
    var title: String
    var image: UIImage
}


class ViewController: UITableViewController {
    
    var photos: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88
        
        let url = URL(string: "https://raw.githubusercontent.com/rishabh-chowdhary/IOSChallenge/master/response.json")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let content = data else {
                print("Error getting the JSON")
                return
            }

            guard let response = try? JSONSerialization.jsonObject(
                with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject else
            {
                print("Bad JSON data")
                return
            }
            
            guard let photos = response["photos"] as? [NSDictionary] else {
                print("No 'photos' in response JSON.")
                return
            }

            for photoInfo in photos {
                guard let title = photoInfo["title"] as? String,
                    let urlString = photoInfo["url"] as? String else
                {
                    print("Dictionary \(photoInfo) is incorrect.")
                    continue
                }
                
                guard let url = URL(string: urlString) else {
                    print("The string \(urlString) is not a URL.")
                    continue
                }
                
                guard let data = try? Data(contentsOf: url) else {
                    print("Failed to download image \(url).")
                    continue
                }
                
                guard let image = UIImage(data: data) else {
                    print("Data downloaded from \(url) doesn't seem to be a valid image file.")
                    continue
                }
                
                let item = Item(title: title, image: image)
                self.photos.append(item)
            }

            self.tableView.reloadData()
        }
        
        task.resume()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.photos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
            as! PhotoCell
        cell.photoLabel.text = item.title
        cell.photoImageView.image = item.image
        return cell
    }
}
