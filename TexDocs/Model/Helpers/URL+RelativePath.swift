//
//  URL+RelativePath.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension URL {
    func path(relativeTo base: URL) -> String? {
        let basePath = base.standardized.path
        guard standardized.path.hasPrefix(basePath) else {
            return nil
        }

        return String(standardized.path[basePath.endIndex...].dropFirst())
    }
}
