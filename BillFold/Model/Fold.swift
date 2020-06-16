//
//  DataModel.swift
//  BillFold
//
//  Created by Simon Schueller on 6/15/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import Foundation
import RealmSwift

class Fold: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date?
    @objc dynamic var color: String = ""
    @objc dynamic var total: Double = 0.0
}
