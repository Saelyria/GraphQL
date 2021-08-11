import Foundation

/**
An object used when adding arguments to a field selection that builds a string of values for a given 'input' object.

This object is specialized with the type of an 'input' object being used as the value for an argument. It is passed into
the closure on that argument, where it is called with the keypaths of the wrapped 'input' type with the input's values.
*/
/*
@dynamicMemberLookup
public class _InputBuilder<I: Input> {
	internal var addedInputFields: [String] = []

    /**
    Adds the given property value to the input object.
    */
    public subscript<Value: Scalar>(
        dynamicMember keyPath: KeyPath<I.SubSchema, Value>
    ) -> (Value) -> Void {
        return { value in
            let schema: I.SubSchema = I.schema
            let _ = schema[keyPath: keyPath]
            guard let fieldKey = I.key(forPath: keyPath) else {
                fatalError("No key set - is this value wrapped in a @Field property wrapper?")
            }
            self.addedInputFields.append("\(fieldKey):\(value.render())")
        }
    }
	
	/**
	Adds the given property value to the input object.
	*/
    public subscript<Value: Scalar, Args: ArgumentsList>(
        dynamicMember keyPath: KeyPath<I.SubSchema, (Value, Args)>
    ) -> (Value) -> Void {
		return { value in
            let _ = I.schema[keyPath: keyPath]
            guard let fieldKey = I.key(forPath: keyPath) else {
                fatalError("No key set - is this value wrapped in a @Field property wrapper?")
            }
			self.addedInputFields.append("\(fieldKey):\(value.render())")
		}
	}
	
	/**
	Adds the given property input object value to the input object.
	*/
    public subscript<Value: Collection, Args: ArgumentsList>(
        dynamicMember keyPath: KeyPath<I.SubSchema, (Value, Args)>
    ) -> ( [(_InputBuilder<Value.Element>) -> Void] ) -> Void
    where Value.Element: Input {
		return { inputBuilders in
            inputBuilders.forEach { (inputBuilder: (_InputBuilder<Value.Element>) -> Void) in
                let b = _InputBuilder<Value.Element>()
                inputBuilder(b)
                let _ = I.schema[keyPath: keyPath]
                guard let fieldKey = I.key(forPath: keyPath) else {
                    fatalError("No key set - is this value wrapped in a @Field property wrapper?")
                }
                let value = "{\(b.addedInputFields.joined(separator: ","))}"
                self.addedInputFields.append("\(fieldKey):\(value)")
            }
		}
	}

    /**
    Adds the given property input object value to the input object.
    */
    public subscript<Value: Input>(
        dynamicMember keyPath: KeyPath<I.SubSchema, Value>
    ) -> ( (_InputBuilder<Value>) -> Void ) -> Void {
        return { inputBuilder in
            let b = _InputBuilder<Value>()
            inputBuilder(b)
            let _ = I.schema[keyPath: keyPath]
            guard let fieldKey = I.key(forPath: keyPath) else {
                fatalError("No key set - is this value wrapped in a @Field property wrapper?")
            }
            let value = "{\(b.addedInputFields.joined(separator: ","))}"
            self.addedInputFields.append("\(fieldKey):\(value)")
        }
    }
}
*/