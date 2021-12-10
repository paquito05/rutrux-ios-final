//
//  DetallesViewController.swift
//  Rutrux
//
//  Created by carlos pumayalla on 11/17/21.
//  Copyright © 2021 empresa. All rights reserved.
//

import UIKit

class DetallesViewController: UIViewController {

    @IBOutlet weak var empresaTxt: UILabel!
    @IBOutlet weak var lineaTxt: UILabel!
    @IBOutlet weak var distritoTxt: UILabel!
    @IBOutlet weak var psjCompletoTxt: UILabel!
    @IBOutlet weak var psjEscolarTxt: UILabel!
    @IBOutlet weak var psjUrbanoTxt: UILabel!
    var empresa = Empresa()
    var linea = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        empresaTxt.text = "Empresa: " + empresa.nombre
        lineaTxt.text = "Linea: " + linea
        distritoTxt.text = "Distrito: " + empresa.distrito
        psjCompletoTxt.text = "Completo: " + empresa.pasajecom
        psjEscolarTxt.text = "Escolar: " + empresa.pasajeesc
        psjUrbanoTxt.text = "Urbano: " + empresa.pasajeur
       
    }
}
