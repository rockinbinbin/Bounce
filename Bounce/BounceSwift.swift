//
//  BounceSwift.swift
//  bounce
//
//  Created by Steven on 8/27/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

/**
    Find the first element in a sequence passing a test.

    :param: source Source sequence to iterate
    :param: includeElement Closure to evaluate elements with
    :return: First element in the sequence for which includeElement returns true, or nil if none found
*/
public func first<S: SequenceType>(source: S, includeElement: (S.Generator.Element) -> Bool) -> S.Generator.Element? {
    var filteredSource = lazy(source).filter(includeElement).generate()
    return filteredSource.next()
}

/**
    Applies a transform to each element in a sequence

    :param: source Source sequence to iterate
    :param: transform Closure to apply to every element
*/
public func each<S: SequenceType>(source: S, transform: (S.Generator.Element) -> Void) {
    for element in source {
        transform(element)
    }
}

/**
    Builds an array by applying a closure to all elements of a given list, and
    using the elements of the resulting collections.

    :param: source Source sequence to iterate
    :param: transform Closure to evaluate elements with
    :return: An array of transformed values
*/
public func flatMap<S: SequenceType, T>(source: S, transform: (S.Generator.Element) -> [T]) -> [T] {
    return reduce(source, []) { (var ret, element) in
        ret += transform(element)
        return ret
    }
}
