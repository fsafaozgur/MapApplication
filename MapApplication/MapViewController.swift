//
//  ViewController.swift
//  MapApplication
//
//  Created by Safa on 23.08.2023.
//  Copyright © 2023 Safa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    var locationName = ""
    var locationId : UUID?
    
    
    var pinTitle = ""
    var pinSubtitle = ""
    var pinLongitude = Double()
    var pinLatitude = Double()
    
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        locationManager.delegate = self
        mapView.delegate = self
        
        //En kesin koordinati istiyoruz, bazi uygulamalarda noktasal degil bolgesel istenebilir, o sebeple bunu ayarlama imkani verilmis
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Yalnizca program kullanilirken konum bilgisine ulasilmasi icin izin istedik, bu izne iliskin ekranda gorulecek metni de Info.plist dosyasina ekledik
        locationManager.requestWhenInUseAuthorization()
        
        //Konum elde etmek icin guncellemeyi baslattik
        locationManager.startUpdatingLocation()
        
        
        //Uzerine birkac saniye basinca algilayan bir Gesture tanimliyoruz ve tiklanilan noktanin bilgisini alabilmek icin, objc Fonksiyon ile Gesturenin kendisini parametre olarak yolluyoruz
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(gestureRecognizer:)))
        
        //En az 3 saniye boyunca mapView uzerine tiklanirsa objc Func tetikle
        gestureRecognizer.minimumPressDuration = 3
        
        //gestureRecognizer i mapView a ekle
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        //Location name bos degil ise o halde tableView den tiklanan hucredeki verilere ait bilgiler ekrana basilmak isteniyordur
        if locationName != "" {
            
            //Veri kayit olmayacagi icin kaydetme tusunu gizliyoruz
            saveButton.isHidden = true
            
            //performSegue ile gelen degiskendeki UUID veriyi sorgulama yapmak icin String turune ceviriyoruz
            if let uuidString = locationId?.uuidString {
                
                
                //Singleton nesne yardimi ile AppDelegate dosyasini bir obje gibi kullaniyoruz
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                //AppDelegate icerisindeki viewContext e ulasiyoruz
                let context = appDelegate.persistentContainer.viewContext
                
                //CoreData icersinde olusturdugumuz entity ye ulasmak icin request gonderiyoruz
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                
                //Filtreleme islemi yaparak secilen Location i getiriyoruz
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                
                do {
                    //Filtrelenmis requestimiz sonucunda sonuc donuyor
                    let results = try context.fetch(fetchRequest)
                    
                    //Sonuc dondumu diye kontrol ediyoruz
                    if results.count > 0 {
                    
                        //Tek veri gelecek olsa da yinede for dongusu kullanmanin sakincasi yok
                        for result in results as! [NSManagedObject] {
                        
                            if let name = result.value(forKey: "name") as? String {
                                pinTitle = name
                                
                                if let description = result.value(forKey: "descriptions") as? String {
                                    pinSubtitle = description
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        pinLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double {
                                            pinLongitude = longitude
                                            
                                            //Anotasyon olusturuluyor
                                            let annotation = MKPointAnnotation()
                                            
                                            //Anotasyon title
                                            annotation.title = pinTitle
                                            
                                            //Anotasyon subtitle
                                            annotation.subtitle = pinSubtitle
                                            
                                            //Enlem-Boylam bilgisi ile koordinat olusturuluyor
                                            let coordinate = CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            //Tum bilgiler ile Anotasyon mapView a ekleniyor
                                            mapView.addAnnotation(annotation)
                                            
                                            //Database den gelen veriler TextField lara dolduruluyor
                                            nameTextField.text = pinTitle
                                            descriptionTextField.text = pinSubtitle
                                            
                                            //Haritanin kullanici konumuna gitmesini engellemek icin konum guncellemesini kapatiyoruz
                                            locationManager.stopUpdatingLocation()
                                            
                                            
                                            //Veri tabanindan aldigimiz koordinatlar ile kayitli konumu gosteriyoruz
                                            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }

                            
                        }
                    }
                } catch {
                    print("error")
                }
            
            }
        
            
        }else {
            
            //Bu scope calistiysa demekki yeni ekleme islemi yapilacaktir, bu sebeple tum TextField lari bosaltiyoruz
            nameTextField.text = ""
            descriptionTextField.text = ""
            
            //Yeni veri girilecegi icin tus gorunur yapiliyor
            saveButton.isHidden = false
            
            //Haritada konum secilene kadar kaydetme tusunu pasif yapiyoruz
            saveButton.isEnabled = false
            
        }
        
        
    }
    
    
    //Haritada biryer secildigi zaman, default olan degil, ozel bir annotation gostermek icin kullanacagimiz fonksiyon
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        //Eger kullanicinin guncel konumu gosterilecekse ozel bir annotation gostermeye gerek yok
        if annotation is MKUserLocation {
            return nil
        }
        
        //Killanici konumu degilse yani harita uzerinden bir nokta secildiyse o halde ozel annotasyon uretiyoruz, yani standart olan annotationa ekleme yapiyoruz
        
        //Ozel annotation a ait bir isim belirleyelim
        let annotationId = "specialAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId)
        
        //Daha once olusturulmadiysa sifirdan olusturmaya basliyoruz
        if pinView == nil {
            
            //Ilk olarak pinView olusturuyoruz
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            
            pinView?.isEnabled = true
            
            //Olusturdugumuz annotation a ekstra bir ozellik eklenecek mi
            pinView?.canShowCallout = true
            
            //Renk veriyoruz
            pinView?.tintColor = .red
            
            //Button tanimlamasini yapiyoruz
            let button = UIButton(type: .detailDisclosure)
            
            //Daha once degistirilebilirligine true verdigimiz CallOut ile bu defa degistirilecek item in ne oldugunu belirtiyoruz
            pinView?.rightCalloutAccessoryView = button
            
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    
    //Annotation a ekledigimiz sag taraftaki detailDisclosure buttonuna tiklandiginda ne olacagini yazdigimiz fonksiyon
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //Yeni kayit yapilirken navigasyona gerek yok, bu sebeple yalnizca veritabanindan getirdigimiz bir konum olursa navigasyona yonlendirelim
        if locationName != "" {
            
            let location = CLLocation(latitude: pinLatitude, longitude: pinLongitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarkArray, error) in
                
                //Dizi bosmu
                if let placemarks = placemarkArray {
                    if placemarks.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.pinTitle
                        
                        //Ilk secenek olarak araba ile gidilecek olarak belirledik, kullanici bunu navigasyondan degistirebilir
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                    }
                    
                }
                
            }
            
            
        }
    }
    
    
    
    //viewMap uzerine bir sure basilinca tetiklenen fonksiyon
    @objc func selectLocation (gestureRecognizer: UILongPressGestureRecognizer) {
        
        //GestureRecognizerin durumu kontrol ediliyor
        if gestureRecognizer.state == .began {
            
            //Dokunulan noktayi tespit ediyoruz
            let touchedLocation = gestureRecognizer.location(in: mapView)
            
            //Dokunulan noktanin koordinatlarini aliyoruz
            let touchedCoordinate = mapView.convert(touchedLocation, toCoordinateFrom: mapView)
            
            //Veri tabanina daha sonradan kayit yapilacagi zaman kullanilmak uzere deger atamasi yapiyoruz
            selectedLatitude = touchedCoordinate.latitude
            selectedLongitude = touchedCoordinate.longitude
            
            //Nesne olusturduk
            let annotation = MKPointAnnotation()
            
            //Koordinat bilgisini verdik
            annotation.coordinate = touchedCoordinate

            //Tiklanilan yerde gosterilecek metin
            annotation.title = nameTextField.text
            
            //Tiklanilan yerde gosterilecek alt metin
            annotation.subtitle = descriptionTextField.text
            
            //Annotation u ekledik
            mapView.addAnnotation(annotation)

            saveButton.isEnabled = true
        
        }
    }
    
    
    
    //Koordinat belirlenince tetiklenen fonksiyon
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locationName == "" {
            
        //Koordinatlar yardimiyla bir location aldik
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        
        //0.1 degerini yukseltirsek haritayi uzaklastirir
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        
        //Location ve Span ile bir region oluturduk
        let region = MKCoordinateRegion(center: location, span: span)

        //Region u mapView icerisinde gosterdik
        mapView.setRegion(region, animated: true)
            
        }
   
    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        
        let application = UIApplication.shared.delegate as! AppDelegate
        let context = application.persistentContainer.viewContext
        
        let savedEntity = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        savedEntity.setValue(nameTextField.text, forKey: "name")
        savedEntity.setValue(descriptionTextField.text, forKey: "descriptions")
        savedEntity.setValue(selectedLatitude, forKey: "latitude")
        savedEntity.setValue(selectedLongitude, forKey: "longitude")
        savedEntity.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("data saved")
        } catch  {
            print("error")
        }
        
        //Veritabanina kayit isleminin ardindan bir onceki ViewController a donup oralarda islem yapmak icin mesaj yolluyoruz
        NotificationCenter.default.post(name: NSNotification.Name("locationSaved"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    


}

