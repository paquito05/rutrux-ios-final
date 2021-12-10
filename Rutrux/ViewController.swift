//
//  ViewController.swift
//  Rutrux
//
//  Created by carlos pumayalla on 11/17/21.
//  Copyright © 2021 empresa. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation
import FirebaseAuth

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var empresaTxt: UITextField!
    @IBOutlet weak var lineaTxt: UITextField!
    @IBOutlet weak var trailingConst: NSLayoutConstraint!
    @IBOutlet weak var leadingConst: NSLayoutConstraint!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var leadingMenu: NSLayoutConstraint!
    @IBOutlet weak var trailingMenu: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomView: UIView!
    let manager = CLLocationManager()
    var empresas:[Empresa] = []
    var lineas:[Linea] = []
    var ruta:[Ruta] = []
    var empresa = Empresa()
    var location: CLLocation = CLLocation()
    
    var empresaPickerView = UIPickerView()
    var lineaPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        empresaTxt.inputView = empresaPickerView
        lineaTxt.inputView = lineaPickerView
        
        empresaTxt.placeholder = "Seleccionar empresa"
        lineaTxt.placeholder = "Seleccionar linea"
        
        empresaPickerView.delegate = self
        empresaPickerView.dataSource = self
        lineaPickerView.delegate = self
        lineaPickerView.dataSource = self
        self.mapView.delegate = self
        
        empresaPickerView.tag = 1
        lineaPickerView.tag = 2
        
        Database.database().reference().child("empresa").observe(DataEventType.childAdded, with: {(snapshot) in
            let empresa = Empresa()
            empresa.nombre = (snapshot.value as! NSDictionary)["nombre"] as! String
            empresa.distrito = (snapshot.value as! NSDictionary)["distrito"] as! String
            empresa.distrito = (snapshot.value as! NSDictionary)["distrito"] as! String
            empresa.pasajecom = (snapshot.value as! NSDictionary)["pasajecom"] as! String
            empresa.pasajeesc = (snapshot.value as! NSDictionary)["pasajeesc"] as! String
            empresa.pasajeur = (snapshot.value as! NSDictionary)["pasajeur"] as! String
            self.empresas.append(empresa)
            
        })
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = true
        mapView.showsUserLocation = true

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    var menuOut = false
    
    @IBAction func menuTapped(_ sender: Any) {
        
        if menuOut == false{
                leadingConst.constant = 200
                trailingConst.constant = -200
                menuOut = true
        }else{
                leadingConst.constant = 0
                trailingConst.constant = 0
                menuOut = false
        }
               
               UIView.animate(withDuration: 0.2,delay: 0.0,options: .curveEaseIn, animations: {
                   self.view.layoutIfNeeded()
               }) {(animationComplete) in
                  print("Animacion completada")
               }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        
        var coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.location = location
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    private var isBottomSheetShown = false

    @IBAction func sheetTapped(_ sender: Any) {
        
        if (isBottomSheetShown)
               {
                   // hide the bottom sheet
                   UIView.animate(withDuration: 0.1, animations: {
                       self.heightConst.constant = 370
                   }) { (status) in
                       self.isBottomSheetShown = false
                       
                       UIView.animate(withDuration: 0.1, animations: {
                           self.heightConst.constant = 15
                        self.trailingConst.constant = self.view.frame.width
                       }) { (status) in
                           // not to be used
                       }
                       // completion code
                   }
               }
               else{
                   // show the bottom sheet
                   
                   UIView.animate(withDuration: 0.1, animations: {
                       self.heightConst.constant = 350
                   }) { (status) in
                       // completion code
                       self.isBottomSheetShown = true
                       UIView.animate(withDuration: 0.1, animations: {
                           self.heightConst.constant = 350
                           self.view.layoutIfNeeded()
                       }) { (status) in
                           
                       }
                   }
               }
    }
    @IBAction func buscarTapped(_ sender: Any) {
        var overlays = self.mapView.overlays
        if overlays.count > 0{
            for overlay in overlays {
                self.mapView.removeOverlay(overlay)
            }
            overlays.remove(at: 0)
        }
        getRuta()
        var points : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            var count = self.ruta.count-1
            for i in 0...count {
                points.append(self.ruta[i].coordinate)
            }
            let polyline = MKPolyline(coordinates: points, count: points.count)
            self.mapView.addOverlay(polyline)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self){
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.fillColor = UIColor.blue
                polylineRenderer.strokeColor = UIColor.blue
                polylineRenderer.lineWidth = 2
            
            return polylineRenderer
     }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    @IBAction func detallesTapped(_ sender: Any) {
         performSegue(withIdentifier: "detallesSegue", sender: empresa)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detallesSegue" {
            let siguienteVC = segue.destination as! DetallesViewController
            siguienteVC.empresa = sender as! Empresa
            siguienteVC.linea = lineaTxt.text!
        }
    }
    @IBAction func salirTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }catch{
            print("Cerrar sesión completo")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getRuta(){
        var idEmpresa = empresaPickerView.selectedRow(inComponent: 0)
        var idLinea = lineaPickerView.selectedRow(inComponent: 0)
        self.ruta.removeAll()
        Database.database().reference().child("empresa").child(String(idEmpresa)).child("lineas").child(String(idLinea)).child("ruta").observe(DataEventType.childAdded, with: {(snapshot) in
            let ruta = Ruta()
            ruta.lat = (snapshot.value as! NSDictionary) ["lat"] as! Double
            ruta.lon = (snapshot.value as! NSDictionary )["lon"] as! Double
            self.ruta.append(ruta)
        })
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return empresas.count
        case 2:
            return lineas.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return empresas[row].nombre
        case 2:
            return lineas[row].nombre
        default:
            return "Data not found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            empresaTxt.text = empresas[row].nombre
            empresaTxt.resignFirstResponder()
            self.lineas.removeAll()
            Database.database().reference().child("empresa").child(String(row)).child("lineas").observe(DataEventType.childAdded, with: {(snapshot) in
                let linea = Linea()
                linea.nombre = (snapshot.value as! NSDictionary)["nombre"] as! String
                self.lineas.append(linea)
            })
            empresa = empresas[row]
        case 2:
            lineaTxt.text = lineas[row].nombre
            lineaTxt.resignFirstResponder()
        default:
            return
        }
    }
}
