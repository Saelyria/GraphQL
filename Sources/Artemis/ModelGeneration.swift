import Foundation

extension String: Error { }

class _Entity {
    enum _EntityType: String {
        case object = "type"
        case input = "input"
        case `enum` = "enum"
        case scalar = "scalar"
        case schema = "schema"
        case interface = "interface"
    }
    var name: String = ""
    var fields: [_Field] = []
    var interfaces: [String] = []
    var entityType: _EntityType = .object
    var documentation: [String] = []
}

class _Field {
    struct _Argument {
        let name: String
        let type: String
    }
    
    var name: String = ""
    var type: String = ""
    var documentation: [String] = []
    var arguments: [_Argument] = []
}

public func generateSwiftFiles(from graphQLFile: String) throws -> [(filename: String, content: String)] {
    // First, create an array of each line of the file
    let lines = graphQLFile.split(separator: "\n")
    
    let linesGroupedByEntity: [[String]] = getLinesGroupedByEntity(in: lines)
    let entities: [_Entity] = try createEntities(fromGroupedLines: linesGroupedByEntity)

	return entities.map { entity in
		let content = createSwiftTypeLines(from: entity).reduce(into: "") { (result, line) in
			result.append(line)
			if line != "\n" {
				result.append("\n")
			}
		}
		return (filename: entity.name, content: content)
	}
}

// MARK: - Intermediate entity generation from GraphQL schema

func getLinesGroupedByEntity(in lines: [Substring]) -> [[String]] {
    // Now, group the lines into the 'entity' (e.g. type, enum, input, etc) that they're associated with. Each 'entity'
    // at this point is an array of associated lines.
    var linesGroupedByEntity: [[String]] = []
    var entityLinesBeingAddedTo: [String]?
    var isBuildingDocumentation = false
    for line in lines {
        // Ignore comment lines (and don't treat them as documentation, either)
        if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") {
            continue
        }
        // if the line contains """ and it's not a single-line comment (e.g. """Documentation"""), flag that we're building
        // documentation.
        if line.contains("\"\"\"") && !(line.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("\"\"\"") && line.count > 3) {
            isBuildingDocumentation.toggle()
        }
        
        if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("scalar") {
            linesGroupedByEntity.append([String(line)])
        }
            
            // Once we encounter an opening curly brace, create a new 'temp entity' (i.e. string array)
        else if ((line.contains("{") && !isBuildingDocumentation) || line.hasPrefix("\"\"\"")) && entityLinesBeingAddedTo == nil {
            entityLinesBeingAddedTo = [String(line)]
        }
            // When we encounter the closing curly brace for an entity, add that line, add the 'temp entity' to the full
            // 'lines grouped by entity', and clear the 'temp entity' so whitespace between entities are removed
        else if line.trimmingCharacters(in: .whitespacesAndNewlines) == "}" && !isBuildingDocumentation {
            entityLinesBeingAddedTo?.append(String(line))
            linesGroupedByEntity.append(entityLinesBeingAddedTo!)
            entityLinesBeingAddedTo = nil
        }
            // Otherwise, add lines to the 'temp entity', if it exists.
        else {
            entityLinesBeingAddedTo?.append(String(line))
        }
    }
    
    return linesGroupedByEntity
}

func createEntities(fromGroupedLines groupedLines: [[String]]) throws -> [_Entity] {
    var entities: [_Entity?] = []
    
    // Each array of strings is a group of lines associated with an entity - map them into full 'entity' objects.
    entities = try groupedLines.map { lines in
        let entity = _Entity()
        
        var fieldDocumentation: [String] = []
        var isBuildingDocumentation = false
        var fieldBeingBuilt: String?
        var fieldArgumentsBeingBuilt: [String] = []
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("\"\"\"") {
                isBuildingDocumentation.toggle()
            }
            if isBuildingDocumentation {
                let docLine = line.replacingOccurrences(of: "\"\"\"", with: "").trimmingCharacters(in: .whitespaces)
                // Assume the comment is for the entity if its 'name' is empty (i.e. we haven't hit the declaration line yet)
                if entity.name == "" && !docLine.isEmpty {
                    entity.documentation.append(docLine)
                }
                    // Otherwise, store the field documentation in the temp 'field documentation' variable for use when the
                    // field object is actually made
                else if !docLine.isEmpty {
                    fieldDocumentation.append(docLine)
                }
                // reset the 'is building docs' flag if the """ is at the end of a doc line.
                if line.trimmingCharacters(in: .whitespacesAndNewlines).count > 3 &&
                    line.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("\"\"\"") {
                    isBuildingDocumentation = false
                }
            }
                // If it's the declaration line, we can get the entity type, name, and implemented interfaces of the entity
            else if line.contains("{") || line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("scalar") {
				guard !line.hasPrefix("{") else {
					throw "Invalid schema - opening curly braces for types must be on the same line"
				}
                let (type, name, interfaces) = try getTypeNameAndInterfacesForEntity(line: line)
                entity.entityType = type
                entity.name = name
                entity.interfaces = interfaces
            }
                // Otherwise, we're building a field.
            else if !line.contains("}") && !line.replacingOccurrences(of: "\"\"\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                /// If the line contains a left bracket, it's the the first line of a field, so create a new 'field being built'.
                /// However, make sure to keep going to the next if...
                if line.contains("(") {
                    fieldBeingBuilt = line
                }
                
                /// If the line (also) contains a right bracket, it's the last line of a field - add up all the arguments that
                /// were built, append this final line, and add a new field to the entity.
                if line.contains(")") {
                    if !line.contains("(") {
                        fieldBeingBuilt?.append(fieldArgumentsBeingBuilt.joined(separator: ","))
                        fieldBeingBuilt?.append(line)
                    }
                    let field = try createField(line: fieldBeingBuilt!)
                    field.documentation = fieldDocumentation
                    fieldDocumentation = []
                    fieldArgumentsBeingBuilt = []
                    entity.fields.append(field)
                    fieldBeingBuilt = nil
                }
                    /// Otherwise, if the line didn't contain a right or left bracket, it's either an argument for a multi-line
                    /// field, or it's a single-line field with no arguments.
                else if !line.contains("(") {
                    /// If we're not already building a field, it's a single-line, arugment-less field. Just build it and add it.
                    if fieldBeingBuilt == nil {
                        let field = try createField(line: line)
                        field.documentation = fieldDocumentation
                        fieldDocumentation = []
                        fieldArgumentsBeingBuilt = []
                        entity.fields.append(field)
                        fieldBeingBuilt = nil
                    } else {
                        /// Otherwise, it's an argument to a field build built - add it to the array of fields.
                        fieldArgumentsBeingBuilt.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
        }
        
        if entity.entityType != .schema {
            return entity
        }
        return nil
    }
    
    return entities.compactMap { $0 }
}

func getTypeNameAndInterfacesForEntity(line: String) throws -> (type: _Entity._EntityType, name: String, interfaces: [String]) {
    var type: _Entity._EntityType = .object
    var name: String = ""
    var interfaces: [String] = []
    
    // Split the given line by the 'implements' keyword (will remove the keyword)
    let lineSplitByImplements = line.components(separatedBy: "implements")
    var nameComponent = lineSplitByImplements[0]
    
    let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Check the prefix of the 'name component' of the line to determine the type of the entity. When the type is
    // determined, remove the entity type from the 'name component'.
    if line.hasPrefix(_Entity._EntityType.object.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.object.rawValue, with: "")
        type = .object
    } else if line.hasPrefix(_Entity._EntityType.input.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.input.rawValue, with: "")
        type = .input
    } else if line.hasPrefix(_Entity._EntityType.enum.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.enum.rawValue, with: "")
        type = .enum
    } else if line.hasPrefix(_Entity._EntityType.scalar.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.scalar.rawValue, with: "")
        type = .scalar
    } else if line.hasPrefix(_Entity._EntityType.schema.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.schema.rawValue, with: "")
        type = .schema
    } else if line.hasPrefix(_Entity._EntityType.interface.rawValue) {
        nameComponent = nameComponent.replacingOccurrences(of: _Entity._EntityType.interface.rawValue, with: "")
        type = .interface
	} else {
		throw "Couldn't determine the entity type from line '\(line)'"
	}
    
    // Then, remove any whitespace in the 'name component' to get the name of the entity.
    nameComponent = nameComponent
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "{", with: "")
    name = nameComponent
	guard name.isEmpty == false || type == .schema else {
		throw "Couldn't determine the name of the type from line '\(line)'"
	}
    
    // Next, get the implemented interfaces. We can do this by just removing whitespace/the opening curly brace on the
    // second item in the split line and splitting them by commas.
    if lineSplitByImplements.count == 2 {
        var interfacesComponent = lineSplitByImplements[1]
        interfacesComponent = interfacesComponent.replacingOccurrences(of: " ", with: "")
        interfacesComponent = interfacesComponent.replacingOccurrences(of: "{", with: "")
        interfaces = interfacesComponent.split(separator: ",").map { String($0) }
    }
    
    return (type, name, interfaces)
}

func createField(line: String) throws -> _Field {
    let field = _Field()
    var lineWithArgsRemoved: String = line
    
    // Build the array of arguments. We do so by getting the regex for an opening and closing paranthesis, then removing
    // whitespace and the parantheses. Then we split that string by commas to get the key-value 'arg' pairs, which can
    // be split by their colon to get the name and type of the argument.
    if let argsRange = line.range(of: #"\((.*?)\)"#, options: .regularExpression) {
        lineWithArgsRemoved.removeSubrange(argsRange)
        
        let args = String(line[argsRange])
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",").map { String($0) }
        for arg in args {
            let nameAndType = arg.split(separator: ":").map { String($0) }
			guard arg.contains(":"), nameAndType.count == 2 else {
				throw "Argument line from line '\(line)' was invalid"
			}
            let name = nameAndType[0]
            let type = getSwiftType(forType: nameAndType[1])
            field.arguments.append(_Field._Argument(name: name, type: type))
        }
    }
    
    // Once we have the line with the arguments portion removed, we can simply perform the same 'remove whitespace/split
    // by colon' algorithm to get the name and type of the field.
    let nameAndType = lineWithArgsRemoved
        .replacingOccurrences(of: " ", with: "")
        .split(separator: ":").map { String($0) }
    field.name = nameAndType[0]
    if nameAndType.count > 1 {
        field.type = getSwiftType(forType: nameAndType[1])
    }
    
    return field
}

// MARK: - Swift types generation from intermediate entities

func createSwiftTypeLines(from entity: _Entity) -> [String] {
    switch entity.entityType {
    case .object:
        return createSwiftLines(forObject: entity)
    case .enum:
        return createSwiftLines(forEnum: entity)
    case .input:
        return createSwiftLines(forInput: entity)
    case .scalar:
        return createSwiftLines(forScalar: entity)
    case .interface:
        return createSwiftLines(forInterface: entity)
    case .schema:
        return []
    }
}

/// Creates the lines of Swift code for a class representing the given intermediate entity.
func createSwiftLines(forObject object: _Entity) -> [String] {
    var lines: [String] = []
    if !object.documentation.isEmpty {
        lines.append("/**")
        lines.append(contentsOf: object.documentation.map { " \($0)" })
        lines.append("*/")
    }
    lines.append("final class \(object.name): Object, ObjectSchema {")
    if !object.interfaces.isEmpty {
        let interfaces = object.interfaces.map { "\($0).self" }.joined(separator: ", ")
        lines.append("   static let implements = Interfaces(\(interfaces))")
    }
    for field in object.fields {
        lines.append("\n")
        if !field.documentation.isEmpty {
            lines.append("   /**")
            lines.append(contentsOf: field.documentation.map { "    \($0)" })
            lines.append("   */")
        }
        if field.arguments.isEmpty {
            lines.append("   var \(getValidPropertyName(forName: field.name)) = Field<\(field.type), NoArguments>(\"\(field.name)\")")
        } else {
            var argumentsNameChars = Array(field.name.appending("Arguments"))
            argumentsNameChars[0] = Character(argumentsNameChars[0].uppercased())
            let argumentsStructName = String(argumentsNameChars)
            lines.append("   var \(getValidPropertyName(forName: field.name)) = Field<\(field.type), \(argumentsStructName)>(\"\(field.name)\")")
            lines.append(contentsOf: createArgumentsStruct(forField: field, name: argumentsStructName))
        }
    }
    lines.append("}")
    return lines
}
func createArgumentsStruct(forField field: _Field, name: String) -> [String] {
    var lines: [String] = []
    lines.append("   final class \(name): ArgumentsList {")
    for argument in field.arguments {
        lines.append("      var \(getValidPropertyName(forName: argument.name)) = Argument<\(argument.type)>(\"\(argument.name)\")")
    }
    lines.append("   }")
    return lines
}

func createSwiftLines(forEnum enumEntity: _Entity) -> [String] {
    var lines: [String] = []
    if !enumEntity.documentation.isEmpty {
        lines.append("/**")
        lines.append(contentsOf: enumEntity.documentation.map { " \($0)" })
        lines.append("*/")
    }
    lines.append("enum \(enumEntity.name): String, Enum {")
    for field in enumEntity.fields {
        if !field.documentation.isEmpty {
            lines.append("   /**")
            lines.append(contentsOf: field.documentation.map { "    \($0)" })
            lines.append("   */")
        }
        lines.append("   case \(field.name) = \"\(field.name)\"")
    }
    lines.append("}")
    return lines
}

func createSwiftLines(forInput input: _Entity) -> [String] {
    var lines: [String] = []
    if !input.documentation.isEmpty {
        lines.append("/**")
        lines.append(contentsOf: input.documentation.map { " \($0)" })
        lines.append("*/")
    }
    lines.append("final class \(input.name): Input, ObjectSchema {")
    for field in input.fields {
        if !field.documentation.isEmpty {
            lines.append("   /**")
            lines.append(contentsOf: field.documentation.map { "    \($0)" })
            lines.append("   */")
        }
        var fieldType: String = field.type
        if field.type.last != "?" {
            fieldType.append("!")
        }
        lines.append("   var \(getValidPropertyName(forName: field.name)): \(fieldType)")
    }
    lines.append("}")
    return lines
}

func createSwiftLines(forScalar scalar: _Entity) -> [String] {
    return ["typealias \(scalar.name) = String"]
}

func createSwiftLines(forInterface object: _Entity) -> [String] {
    var lines: [String] = []
    if !object.documentation.isEmpty {
        lines.append("/**")
        lines.append(contentsOf: object.documentation.map { " \($0)" })
        lines.append("*/")
    }
    lines.append("final class \(object.name): Interface {")
    for field in object.fields {
        lines.append("\n")
        if !field.documentation.isEmpty {
            lines.append("   /**")
            lines.append(contentsOf: field.documentation.map { "    \($0)" })
            lines.append("   */")
        }
        if field.arguments.isEmpty {
            lines.append("   var \(getValidPropertyName(forName: field.name)) = Field<\(field.type), NoArguments>(\"\(field.name)\")")
        } else {
            var argumentsNameChars = Array(field.name.appending("Arguments"))
            argumentsNameChars[0] = Character(argumentsNameChars[0].uppercased())
            let argumentsStructName = String(argumentsNameChars)
            lines.append("   var \(getValidPropertyName(forName: field.name)) = Field<\(field.type), \(argumentsStructName)>(\"\(field.name)\")")
            lines.append(contentsOf: createArgumentsStruct(forField: field, name: argumentsStructName))
        }
    }
    lines.append("}")
    return lines
}

func getSwiftType(forType type: String) -> String {
    if type.contains("]") {
        var arrayElementType = type
        if type.hasSuffix("!") {
            arrayElementType.removeLast()
            arrayElementType = arrayElementType.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            arrayElementType = "[\(getSwiftType(forType: arrayElementType))]"
        } else {
            arrayElementType = arrayElementType.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            arrayElementType = "[\(getSwiftType(forType: arrayElementType))]?"
        }
        return arrayElementType
    }
    
    let optionalsAccountedType: String
    if type.contains("!") {
        optionalsAccountedType = type.replacingOccurrences(of: "!", with: "")
    } else {
        optionalsAccountedType = type.appending("?")
    }
    return optionalsAccountedType
        .replacingOccurrences(of: "Boolean", with: "Bool")
}

func getValidPropertyName(forName name: String) -> String {
    func createTemplate(invalidName: String) -> String {
        var template = "<#invalid property name '\(invalidName)' - provide a new name"
        template.append("#>")
        return template
    }
    
    var invalidNameTemplate: String?
    if name == "class" {
        invalidNameTemplate = "`class`"
    } else if name == "self" {
        invalidNameTemplate = createTemplate(invalidName: "self")
    } else if name == "type" {
        invalidNameTemplate = createTemplate(invalidName: "type")
    } else if name == "struct" {
        invalidNameTemplate = createTemplate(invalidName: "struct")
    } else if name == "struct" {
        invalidNameTemplate = createTemplate(invalidName: "struct")
    }
    return invalidNameTemplate ?? name
}

private let reservedKeywords = ["associatedtype", "class", "deinit", "enum", "extension",
                                "fileprivate", "func", "import", "init", "inout", "internal", "let", "open",
                                "operator", "private", "protocol", "public", "static", "struct", "subscript",
                                "typealias", "var", "break", "case", "continue", "default", "defer", "do",
                                "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return",
                                "switch", "where", "while", "as", "Any", "catch", "false", "is", "nil",
                                "rethrows", "super", "self", "Self", "throw", "throws", "true", "try",
                                "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix",
                                "indirect", "lazy", "left", "mutating", "none", "nonmutating", "optional",
                                "override", "postfix", "precedence", "prefix", "Protocol", "required", "right",
                                "set", "Type", "unowned", "weak", "willSet"]
