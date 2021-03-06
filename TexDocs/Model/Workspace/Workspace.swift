//
//  Workspace.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class Workspace: NSPersistentDocument {
    var workspaceURL: URL? {
        return fileURL?.deletingLastPathComponent()
    }

    lazy var workspaceModel: WorkspaceModel = managedObjectContext!.fetchOrCreateWorkspaceModel()
    let databaseQueue = DispatchQueue(label: "Workspace Queue")

    override init() {
        super.init()
        setUp()
    }

    init(openMethod: NewProjectOpenMethod) {
        super.init()
        workspaceModel.serverURL = openMethod.serverURL
        workspaceModel.serverProjectUUID = openMethod.projectID
        setUp()
    }

    func setUp() {
        managedObjectContext?.undoManager = nil
    }

    var mainWindowController: EditorWindowController?

    override class var autosavesInPlace: Bool {
        return true
    }

    override func write(to absoluteURL: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, originalContentsURL absoluteOriginalContentsURL: URL?) throws {
        try super.write(to: absoluteURL, ofType: typeName, for: saveOperation, originalContentsURL: absoluteURL)
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains the Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        // swiftlint:disable force_cast
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DocumentWindowController")) as! EditorWindowController
        mainWindowController = windowController
        workspaceModel.collaborationDelegate = windowController
        self.addWindowController(windowController)
    }

    override func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) throws -> NSPrintOperation {
        guard let editor = mainWindowController?.editorWrapperViewController.openedEditorController else {
            throw DocumentError.noEditorOpened
        }

        guard let printOperation = editor.printOperation(withSettings: printSettings) else {
            throw DocumentError.notPrintable
        }

        return printOperation
    }
}

enum DocumentError: Error {
    case noEditorOpened
    case notPrintable
}
