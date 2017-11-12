//
//  EditorWindowController+CollaborationSourceCodeViewDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: CollaborationSourceCodeViewDelegate {
    func textDidChange(in range: NSRange, replacementString: String, byUser: Bool) {
        print(replacementString)
    }
    
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor] {
        return client.collaborationCursors.map { return $1 }
    }
}