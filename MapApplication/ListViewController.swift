//
//  ListViewController.swift
//  MapApplication
//
//  Created by Safa on 24.08.2023.
//  Copyright © 2023 Safa. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedName = ""
    var selectedId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Add butonunu ekledik
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        fetchFromDB()
    }
    
    
    //Veri kaydediltikten sonra gelen veriyi observer ile bekliyoruz ve tum verileri tekrar listeleyerek ekrana guncel listeyi basiyoruz
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromDB), name: NSNotification.Name(rawValue: "locationSaved"), object: nil)
    
    }
    
 
    //NotificationCenter tarafindan kullanilacagi icin @objc yaptik yoksa normal bir fonksiyon olarak kullanilabilirdi
    @objc func fetchFromDB() {
        
        //Singleton nesne yardimi ile AppDelegate dosyasini bir obje gibi kullaniyoruz
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //AppDelegate icerisindeki viewContext e ulasiyoruz
        let context = appDelegate.persistentContainer.viewContext
        
        //CoreData icersinde olusturdugumuz entity ye ulasmak icin request gonderiyoruz
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            //Requestimiz sonucunda sonuclar donuyor
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                //Ayni verileri her sayfaya yeni gelinince ekleye ekleye sayfaya basmasin diye sifirliyoruz
                nameArray.removeAll(keepingCapacity: false)
                idArray.removeAll(keepingCapacity: false)
                
                //Verileri NSManagedObject turunden aliyoruz
                for result in results as! [NSManagedObject] {
                    
                    if let name  = result.value(forKey: "name") as? String {
                        
                        nameArray.append(name)
                    }
                    
                     if let id  = result.value(forKey: "id") as? UUID {
                                   
                        idArray.append(id)
                    }
                               
                }
                
            }
         
        } catch  {
            print("error")
        }
        
        //Ekrana guncel liste gelsin diye yeniliyoruz
        tableView.reloadData()
    }
    
    
    //Add butonuna tiklaninca kayit sayfasina gidiyoruz
    @objc func addButtonClicked() {
        
        selectedName = ""
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Secilen Table View hucresinin bilgilerini degiskenlere atiyoruz
        selectedName = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        
        //Bilgileri prepare fonksiyonu ile MapViewControl icerisindeki degiskenlere atadiktan sonra gecis yapiyoruz
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    //performSegue() fonksiyonu tetiklendigi an atama bu fonksiyon calisarak MapViewControl iverisindeki degiskenlere atama yapiyoruz
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            
            //MapViewController i bir nesne gibi olusturuyoruz
            let destination = segue.destination as! MapViewController
            
            //Nesnenin degiskenlerine atama yapiyoruz ki textField lar bu bilgilerle doldurulabilsin
            destination.locationName = selectedName
            destination.locationId = selectedId
            
        }
    }
}
