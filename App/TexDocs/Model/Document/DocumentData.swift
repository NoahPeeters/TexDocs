//
//  DocumentData.swift
//  TexDocs
//
//  Created by Noah Peeters on 13.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

/// Data used for saving and loading a project.
struct DocumentData: Codable {
    
    /// Collaboration data of the project.
    var collaboration: Collaboration?
    
    /// Name of the repository folder.
    var dataFolderName: String

    var schemes: [Scheme]

    func scheme(withUUID uuid: UUID) -> Scheme? {
        return schemes.first { $0.uuid == uuid }
    }
    
    /// Initializes the document data for a new project.
    ///
    /// - Parameter method: The method used to open the project.
    init(open method: NewProjectOpenMethod, dataFolderName: String) {
        switch method {
        case .create(let serverURL, let repositoryURL):
            collaboration = Collaboration(
                server: Collaboration.Server(baseURL: serverURL, projectID: nil),
                repository: Collaboration.Repository(url: repositoryURL))
        case .join(let serverURL, let projectID):
            collaboration = Collaboration(server: Collaboration.Server(
                baseURL: serverURL,
                projectID: projectID))
        case .offline:
            collaboration = nil
        }
        self.dataFolderName = dataFolderName
        self.schemes = []
    }
    
    /// Data required for collaboration.
    struct Collaboration: Codable {
        /// Collaboration server used for live collaboration.
        var server: Server
        
        /// Repository used for offline collaboration.
        var repository: Repository?

        var joinURL: URL? {
            guard let projectID = server.projectID else {
                return nil
            }
            return server.baseURL.appendingPathComponent("project/join/\(projectID)")
        }

        var shareURL: URL? {
            guard let projectID = server.projectID else {
                return nil
            }
            return server.baseURL.appendingPathComponent("?\(projectID)")
        }

        var createURL: URL? {
            guard let gitURL = repository?.url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }
            return URL(string: server.baseURL.appendingPathComponent("project/create/").absoluteString + gitURL)
        }
        
        /// Initializes collaboration data with at least a collaboration server.
        ///
        /// - Parameters:
        ///   - server: Collaboration server used for live collaboration.
        ///   - repository: Repository used for offline collaboration.
        init(server: Server, repository: Repository? = nil) {
            self.server = server
            self.repository = repository
        }
        
        struct Server: Codable {
            /// Collaboration web socket server url.
            let baseURL: URL
            var projectID: String?
            
            /// Initializes collaboration server data with a url.
            ///
            /// - Parameter url: WebSocketServer url.
            init(baseURL: URL, projectID: String?) {
                self.baseURL = baseURL
                self.projectID = projectID
            }
        }
        
        struct Repository: Codable {
            /// Git repository url
            let url: URL
            
            /// Initializes repository data with a url.
            ///
            /// - Parameter url: Git url.
            init(url: URL) {
                self.url = url
            }
        }
    }

    class Scheme: Codable {
        let uuid: UUID
        var name: String
        var path: String

        init(name: String, path: String) {
            self.uuid = UUID()
            self.name = name
            self.path = path
        }
    }
}

extension DocumentData {
    /// Collaboration status of the project
    var isCollaborationEnabled: Bool {
        return collaboration != nil
    }
}