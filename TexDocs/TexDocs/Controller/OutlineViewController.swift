//
//  OutlineViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController {
    @IBOutlet weak var outlineView: NSOutlineView!
    
    weak var delegate: OutlineViewControllerDelegate?
    
    func reloadData(expandAll: Bool = false) {
        outlineView.reloadData()
        if expandAll {
            outlineView.expandItem(delegate?.rootDirectory, expandChildren: true)
        }
    }
}

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? FileSystemItem else { return 1 }
        
        return item.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileSystemItem else {
            return (delegate?.rootDirectory as Any?) ?? 0
        }
        
        return item.children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileSystemItem else { return false }
        return item.numberOfChildren > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileSystemItem else { return nil }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileSystemItemCell"), owner: nil) as! FileSystemItemCell
        cell.iconView.image = NSWorkspace.shared.icon(forFile: item.url.path)
        cell.nameTextField.stringValue = item.url.lastPathComponent
        return cell
    }
}

extension OutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let item = item as? FileSystemItem else { return false }
        
        print(item.url)
        return true
    }
}

protocol OutlineViewControllerDelegate: class {
    var rootDirectory: FileSystemItem? { get }
    func selected(item: FileSystemItem)
}

class FileSystemItem: NSObject {
    var numberOfChildren: Int {
        return children.count
    }
    let url: URL
    
    var children: [FileSystemItem] = []
    
    var name: String {
        return url.lastPathComponent
    }
    
    var isDirectory: Bool {
        return url.hasDirectoryPath
    }
    
    init(_ url: URL) {
        self.url = url
        super.init()
        
        updateChildren()
    }
    
    private func subURLs() -> [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])) ?? []
    }
    
    func updateChildren() {
        let newChildrenURLs = subURLs()
        
        children = children.filter { newChildrenURLs.contains($0.url) }
        
        children.append(contentsOf: newChildrenURLs.filter { url in
            !children.contains { child in
                child.url == url
            }
        }.fileSystemItems())
        
        children.sort {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }
}

extension Array where Element == URL {
    func fileSystemItems() -> [FileSystemItem] {
        return map {
            FileSystemItem($0)
        }
    }
}
