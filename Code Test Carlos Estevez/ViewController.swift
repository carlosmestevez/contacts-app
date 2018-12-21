//
//  ViewController.swift
//  Code Test Carlos Estevez
//
//  Created by Carlos Estevez on 12/18/18.
//  Copyright © 2018 Carlos Estevez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var contacts:[Contact] = []
    var filteredContacts:[Contact]? = nil
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        let decoded  = userDefaults.object(forKey: "contacts")
        if decoded != nil {
            let data = decoded as! Data
            
            do {
                contacts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Contact]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        contacts = contacts.sorted(by: { $0.fullName < $1.fullName })
        filteredContacts = contacts
        
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        contactsTableView.tableHeaderView = searchController.searchBar
        
        self.contactsTableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if (editing && !contactsTableView.isEditing) {
            contactsTableView.setEditing(true, animated: true)
            self.editButtonItem.title = "Done"
            self.editButtonItem.style = .done
        } else{
            contactsTableView.setEditing(false, animated: true)
            self.editButtonItem.title = "Edit"
            self.editButtonItem.style = .plain
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowContact" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = contactsTableView.indexPathForSelectedRow
            let selectedContact = filteredContacts![indexPath!.row]
            detailViewController.contact = selectedContact
        }
    }

    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { $0.fullName.lowercased().contains(searchController.searchBar.text!.lowercased()) }
            
            if filteredContacts!.isEmpty {
                filteredContacts = contacts.filter { $0.emails.joined(separator: " ").lowercased().contains(searchController.searchBar.text!.lowercased()) }
            }
            
            if filteredContacts!.isEmpty {
                filteredContacts = contacts.filter { $0.phoneNumbers.joined(separator: " ").lowercased().contains(searchController.searchBar.text!.lowercased()) }
            }
        }
        
        self.contactsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as! ContactsViewCell
        
        cell.fullNameLabel.text = filteredContacts![indexPath.row].fullName
        
        //save original row numbers
        if searchController.searchBar.text! == "" {
            contacts[indexPath.row].id = indexPath.row
            filteredContacts![indexPath.row].id = indexPath.row
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contacts.remove(at: indexPath.row)
            filteredContacts!.remove(at: indexPath.row)
            saveData()
            contactsTableView.reloadData()
        }
    }
    
    
    func saveData() {
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: contacts, requiringSecureCoding: false)
            userDefaults.set(encodedData, forKey: "contacts")
            userDefaults.synchronize()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func unwindToContactList(sender: UIStoryboardSegue) {
        let sourceViewController = sender.source as! DetailViewController
        let contact = sourceViewController.contact
        
        if (contactsTableView!.indexPathForSelectedRow != nil) {
            //update
            contacts[(contact?.id)!] = contact!
            contacts = contacts.sorted(by: { $0.fullName < $1.fullName })
            
            for (index, filteredContact) in (filteredContacts?.enumerated())! {
                if filteredContact.id == contact?.id {
                    filteredContacts![index] = contact!
                    break
                }
            }
        } else {
            //add
            contacts.append(contact!)
            contacts = contacts.sorted(by: { $0.fullName < $1.fullName })
            filteredContacts = contacts
        }
        
        saveData()
        contactsTableView.reloadData()
    }
}
