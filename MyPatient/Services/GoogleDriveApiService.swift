//
//  GoogleDriveApiService.swift
//  MyPatients
//
//  Created by Serhii Khomych on 11.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class GoogleDriveApiService {
    
    func getFolderID(name: String, service: GTLRDriveService, user: GIDGoogleUser, completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        
        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
        
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folderList = result as! GTLRDrive_FileList
            
            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
        }
    }
    
    func createFolder(name: String, parentFolderID: String, service: GTLRDriveService, completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        if  parentFolderID != "" {
            folder.parents = [parentFolderID]
        }
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        service.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    func uploadFile(name: String, folderID: String, fileURL: URL, mimeType: String, service: GTLRDriveService, completion: @escaping (URL) -> Void) {
        
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]
        
        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion(fileURL)
        }
    }
}
