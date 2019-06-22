import Foundation

// MARK: - Adding fragments of conforming types to an interface sub-selection

public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T.ImplementedInterfaces.I1 == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T.ImplementedInterfaces.I2 == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T.ImplementedInterfaces.I3 == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T.ImplementedInterfaces.I4 == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T.ImplementedInterfaces.I5 == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}


// MARK: - Adding fragments of conformed interfaces to a type sub-selection

public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T.ImplementedInterfaces.I1 {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T.ImplementedInterfaces.I2 {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T.ImplementedInterfaces.I3 {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T.ImplementedInterfaces.I4 {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}
public extension Add where SubSelection == EmptySubSelection, F: AnyFragment, F.T == T.ImplementedInterfaces.I5 {
    convenience init(fragment: F) {
        self.init(fieldType: .fragment(rendered: fragment.render()))
    }
}