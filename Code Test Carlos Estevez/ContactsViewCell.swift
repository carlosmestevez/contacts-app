//
//  ContactsViewCell.swift
//  Code Test Carlos Estevez
//
//  Created by Carlos Estevez on 12/20/18.
//  Copyright © 2018 Carlos Estevez. All rights reserved.
//

import UIKit

class ContactsViewCell:UITableViewCell {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
