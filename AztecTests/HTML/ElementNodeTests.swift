import XCTest
@testable import Aztec

class ElementNodeTests: XCTestCase {

    typealias Attribute = Libxml2.Attribute
    typealias ElementNode = Libxml2.ElementNode
    typealias RootNode = Libxml2.RootNode
    typealias StringAttribute = Libxml2.StringAttribute
    typealias TextNode = Libxml2.TextNode

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Whenever there's a single element node, make sure method `lowestElementNodeWrapping(range:)`
    /// returns the element node, as expected.
    ///
    func testThatLowestElementNodeWrappingRangeWorksWithASingleElementNode() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: text1.length(), length: text2.length())

        let node = mainNode.lowestElementNodeWrapping(range)

        XCTAssertEqual(node, mainNode)
    }

    /// Whenever the range is inside a child node, make sure that child node is returned.
    ///
    func testThatLowestElementNodeWrappingRangeWorksWithAChildNode1() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let childNode = ElementNode(name: "em", attributes: [], children: [text2])

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, childNode, text3])
        let range = NSRange(location: text1.length(), length: text2.length())

        let node = mainNode.lowestElementNodeWrapping(range)

        XCTAssertEqual(node, childNode)
    }

    /// Whenever the range is not strictly inside any child node, make sure the parent node is
    /// returned instead.
    ///
    func testThatLowestElementNodeWrappingRangeWorksWithAChildNode2() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let childNode = ElementNode(name: "em", attributes: [], children: [text2])

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, childNode, text3])
        let range = NSRange(location: text1.length() - 1, length: text2.length() + 2)

        let node = mainNode.lowestElementNodeWrapping(range)

        XCTAssertEqual(node, mainNode)
    }

    /// Whenever there's a single element node, make sure method `lowestTextNodeWrapping(range:)`
    /// returns the text node, as expected.
    ///
    func testThatLowestTextNodeWrappingRangeWorksWithASingleElementNode() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: text1.length(), length: text2.length())

        let node = mainNode.lowestTextNodeWrapping(range)

        XCTAssertEqual(node, text2)
    }

    /// Whenever the range is inside a child node, make sure that child node is returned.
    ///
    func testThatLowestTextNodeWrappingRangeWorksWithAChildNode1() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let childNode = ElementNode(name: "em", attributes: [], children: [text2])

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, childNode, text3])
        let range = NSRange(location: text1.length(), length: text2.length())

        let node = mainNode.lowestTextNodeWrapping(range)

        XCTAssertEqual(node, text2)
    }

    /// Whenever the range is not strictly inside any child node, make sure the parent node is
    /// returned instead.
    ///
    func testThatLowestTextNodeWrappingRangeWorksWithAChildNode2() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let childNode = ElementNode(name: "em", attributes: [], children: [text2])

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, childNode, text3])
        let range = NSRange(location: text1.length() - 1, length: text2.length() + 2)

        let node = mainNode.lowestTextNodeWrapping(range)
        
        XCTAssertEqual(node, nil)
    }

    /// Tries to obtain the lowest block-level elements intersecting the specified range.
    ///
    /// HTML string: <p>Hello <b>world</b>!</p>
    /// Range: (6...5)
    ///
    /// The result should be: 
    ///     - element: the main paragraph
    ///     - range: (6...5)
    ///
    func testEnumerateBlockLowestElementsIntersectingRange() {

        let textNode1 = TextNode(text: "Hello ")
        let textNode2 = TextNode(text: "world")
        let textNode3 = TextNode(text: "!")
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1, boldNode, textNode3])

        let range = NSRange(location: textNode1.length(), length: textNode2.length())
        let atLeastOneElementFound = expectationWithDescription("At least one elements should be returned in the enumeration.")

        paragraph.enumerateLowestBlockLevelElements(intersectingRange: range) { (element, intersection) in
            XCTAssertEqual(element, paragraph)
            XCTAssertEqual(intersection.location, range.location)
            XCTAssertEqual(intersection.length, range.length)
            atLeastOneElementFound.fulfill()
        }
        waitForExpectationsWithTimeout(0) { (error) in
            if let error = error {
                XCTFail(error.description)
            }
        }
    }
    
    func testLeafNodesWrappingRange1() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here")
        let text3 = TextNode(text: "text3 goes here")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: 0, length: mainNode.length())

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 3)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text1)
        XCTAssertEqual(nodesAndRanges[1].node as? TextNode, text2)
        XCTAssertEqual(nodesAndRanges[2].node as? TextNode, text3)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 0, length: text1.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[1].range, NSRange(location: 0, length: text2.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[2].range, NSRange(location: 0, length: text3.length())))
    }

    func testLeafNodesWrappingRange2() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: 0, length: mainNode.length() - 1)

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 3)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text1)
        XCTAssertEqual(nodesAndRanges[1].node as? TextNode, text2)
        XCTAssertEqual(nodesAndRanges[2].node as? TextNode, text3)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 0, length: text1.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[1].range, NSRange(location: 0, length: text2.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[2].range, NSRange(location: 0, length: text3.length() - 1)))
    }

    func testLeafNodesWrappingRange3() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: 1, length: mainNode.length() - 1)

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 3)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text1)
        XCTAssertEqual(nodesAndRanges[1].node as? TextNode, text2)
        XCTAssertEqual(nodesAndRanges[2].node as? TextNode, text3)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 1, length: text1.length() - 1)))
        XCTAssert(NSEqualRanges(nodesAndRanges[1].range, NSRange(location: 0, length: text2.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[2].range, NSRange(location: 0, length: text3.length())))
    }

    func testLeafNodesWrappingRange4() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: text1.length(), length: mainNode.length() - text1.length())

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 2)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text2)
        XCTAssertEqual(nodesAndRanges[1].node as? TextNode, text3)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 0, length: text2.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[1].range, NSRange(location: 0, length: text3.length())))
    }

    func testLeafNodesWrappingRange5() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: 0, length: mainNode.length() - text3.length())

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 2)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text1)
        XCTAssertEqual(nodesAndRanges[1].node as? TextNode, text2)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 0, length: text1.length())))
        XCTAssert(NSEqualRanges(nodesAndRanges[1].range, NSRange(location: 0, length: text2.length())))
    }

    func testLeafNodesWrappingRange6() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: text1.length(), length: 0)

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 1)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text2)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: 0, length: 0)))
    }

    func testLeafNodesWrappingRange7() {
        let text1 = TextNode(text: "text1 goes here")
        let text2 = TextNode(text: "text2 goes here.")
        let text3 = TextNode(text: "text3 goes here..")

        let mainNode = ElementNode(name: "p", attributes: [], children: [text1, text2, text3])
        let range = NSRange(location: text1.length() - 1, length: 0)

        let nodesAndRanges = mainNode.leafNodesWrapping(range)

        XCTAssertEqual(nodesAndRanges.count, 1)
        XCTAssertEqual(nodesAndRanges[0].node as? TextNode, text1)

        XCTAssert(NSEqualRanges(nodesAndRanges[0].range, NSRange(location: text1.length() - 1, length: 0)))
    }
    
    /// Tests that splitting an element node at a specified text location works fine.
    ///
    /// HTML string: <div><p>Hello World!</p></div>
    /// Split target: the paragraph tag
    /// Split Location: 5
    ///
    /// The results should be:
    ///     - The output should be: <div><p>Hello</p><p> World!</p></div>
    ///     - The original paragraph object should point to the first child paragraph.
    ///
    func testSplitAtLocation1() {
        let text1 = "Hello"
        let text2 = " World!"
        
        let textNode = TextNode(text: "\(text1)\(text2)")
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode])
        let div = ElementNode(name: "div", attributes: [], children: [paragraph])
        
        let splitLocation = text1.characters.count
        
        paragraph.split(atLocation: splitLocation)
        
        XCTAssertEqual(div.children.count, 2)
        
        guard let newParagraph1 = div.children[0] as? ElementNode
            where newParagraph1 == paragraph && newParagraph1.text() == text1 else {
                XCTFail("Expected the first new paragraph to exist and be the same as the original paragraph.")
                return
        }
        
        guard let newParagraph2 = div.children[1] as? ElementNode
            where newParagraph2.text() == text2 else {
                XCTFail("Expected the first new paragraph to exist.")
                return
        }
    }
    
    /// Tests that splitting an element node at a specified text location works fine.
    ///
    /// HTML string: <div><p>Hello World!</p></div>
    /// Split target: the paragraph tag
    /// Split Location: 0
    ///
    /// The results should be:
    ///     - The output match the input, no splitting should occur.
    ///
    func testSplitAtLocation2() {
        
        let text = "Hello World!"
        let textNode = TextNode(text: text)
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode])
        let div = ElementNode(name: "div", attributes: [], children: [paragraph])
        
        let splitLocation = 0
        
        paragraph.split(atLocation: splitLocation)
        
        XCTAssertEqual(div.children.count, 1)
        XCTAssertEqual(div.children[0], paragraph)
        XCTAssertEqual(paragraph.children.count, 1)
        XCTAssertEqual(paragraph.children[0], textNode)
        XCTAssertEqual(paragraph.text(), "Hello World!")
    }
    
    /// Tests that splitting an element node at a specified text location works fine.
    ///
    /// HTML string: <div><p>Hello World!</p></div>
    /// Split target: the paragraph tag
    /// Split Location: full string length
    ///
    /// The results should be:
    ///     - The output match the input, no splitting should occur.
    ///
    func testSplitAtLocation3() {
        
        let text = "Hello World!"
        let textNode = TextNode(text: text)
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode])
        let div = ElementNode(name: "div", attributes: [], children: [paragraph])
        
        let splitLocation = text.characters.count
        
        paragraph.split(atLocation: splitLocation - 1)
        
        XCTAssertEqual(div.children.count, 1)
        XCTAssertEqual(div.children[0], paragraph)
        XCTAssertEqual(paragraph.children.count, 1)
        XCTAssertEqual(paragraph.children[0], textNode)
        XCTAssertEqual(paragraph.text(), "Hello World!")
    }

    func testSplitWithFullRange() {

        let textNode = TextNode(text: "Some text goes here")
        let elemNode = ElementNode(name: "SomeNode", attributes: [], children: [textNode])
        let rootNode = RootNode(children: [elemNode])

        let splitRange = NSRange(location: 0, length: textNode.length())

        elemNode.split(forRange: splitRange)

        XCTAssertEqual(rootNode.children.count, 1)
        XCTAssertEqual(rootNode.children[0], elemNode)

        XCTAssertEqual(elemNode.children.count, 1)
        XCTAssertEqual(elemNode.children[0], textNode)
    }

    func testSplitWithPartialRange1() {

        let elemNodeName = "SomeNode"
        let textPart1 = "Some"
        let textPart2 = " text goes here"
        let fullText = "\(textPart1)\(textPart2)"

        let textNode = TextNode(text: fullText)
        let elemNode = ElementNode(name: elemNodeName, attributes: [], children: [textNode])
        let rootNode = RootNode(children: [elemNode])

        let splitRange = NSRange(location: 0, length: textPart1.characters.count)

        elemNode.split(forRange: splitRange)

        XCTAssertEqual(rootNode.children.count, 2)

        XCTAssertEqual(rootNode.children[0].name, elemNodeName)
        XCTAssertEqual(rootNode.children[1].name, elemNodeName)

        guard let elemNode1 = rootNode.children[0] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        guard let elemNode2 = rootNode.children[1] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        XCTAssertEqual(elemNode1.children.count, 1)
        XCTAssertEqual(elemNode2.children.count, 1)

        guard let textNode1 = elemNode1.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        guard let textNode2 = elemNode2.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        XCTAssertEqual(textNode1.text(), textPart1)
        XCTAssertEqual(textNode2.text(), textPart2)
    }

    func testSplitWithPartialRange2() {

        let elemNodeName = "SomeNode"
        let textPart1 = "Some"
        let textPart2 = " text goes here"
        let fullText = "\(textPart1)\(textPart2)"

        let textNode = TextNode(text: fullText)
        let elemNode = ElementNode(name: elemNodeName, attributes: [], children: [textNode])
        let rootNode = RootNode(children: [elemNode])

        let splitRange = NSRange(location: textPart1.characters.count, length: textPart2.characters.count)

        elemNode.split(forRange: splitRange)

        XCTAssertEqual(rootNode.children.count, 2)

        XCTAssertEqual(rootNode.children[0].name, elemNodeName)
        XCTAssertEqual(rootNode.children[1].name, elemNodeName)

        guard let elemNode1 = rootNode.children[0] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        guard let elemNode2 = rootNode.children[1] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        XCTAssertEqual(elemNode1.children.count, 1)
        XCTAssertEqual(elemNode2.children.count, 1)

        guard let textNode1 = elemNode1.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        guard let textNode2 = elemNode2.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        XCTAssertEqual(textNode1.text(), textPart1)
        XCTAssertEqual(textNode2.text(), textPart2)
    }


    func testSplitWithPartialRange3() {

        let elemNodeName = "SomeNode"
        let textPart1 = "Some"
        let textPart2 = " text goes "
        let textPart3 = "here"
        let fullText = "\(textPart1)\(textPart2)\(textPart3)"

        let textNode = TextNode(text: fullText)
        let elemNode = ElementNode(name: elemNodeName, attributes: [], children: [textNode])
        let rootNode = RootNode(children: [elemNode])

        let splitRange = NSRange(location: textPart1.characters.count, length: textPart2.characters.count)

        elemNode.split(forRange: splitRange)

        XCTAssertEqual(rootNode.children.count, 3)

        XCTAssertEqual(rootNode.children[0].name, elemNodeName)
        XCTAssertEqual(rootNode.children[1].name, elemNodeName)
        XCTAssertEqual(rootNode.children[2].name, elemNodeName)

        guard let elemNode1 = rootNode.children[0] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        guard let elemNode2 = rootNode.children[1] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        guard let elemNode3 = rootNode.children[2] as? ElementNode else {
            XCTFail("Expected an element node.")
            return
        }

        XCTAssertEqual(elemNode1.children.count, 1)
        XCTAssertEqual(elemNode2.children.count, 1)
        XCTAssertEqual(elemNode3.children.count, 1)

        guard let textNode1 = elemNode1.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        guard let textNode2 = elemNode2.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        guard let textNode3 = elemNode3.children[0] as? TextNode else {
            XCTFail("Expected a text node.")
            return
        }

        XCTAssertEqual(textNode1.text(), textPart1)
        XCTAssertEqual(textNode2.text(), textPart2)
        XCTAssertEqual(textNode3.text(), textPart3)
    }

    /// Tests obtaining the block-level elements intercepting the full range of the following
    /// HTML string: <div>Hello <p>there</p></div>
    ///
    /// The results should be:
    ///     - (node: div, range: (0...6))
    ///     - (node: p, range: (0...5))
    ///
    func testLowestBlockLevelElements1() {

        let textPart1 = "Hello "
        let textPart2 = "there"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode2])
        let div = ElementNode(name: "div", attributes: [], children: [textNode1, paragraph])

        let results = div.lowestBlockLevelElements(intersectingRange: div.range())

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].element.name, "div")
        XCTAssertEqual(results[0].intersection.location, 0)
        XCTAssertEqual(results[0].intersection.length, 6)
        XCTAssertEqual(results[1].element.name, "p")
        XCTAssertEqual(results[1].intersection.location, 0)
        XCTAssertEqual(results[1].intersection.length, 5)
    }

    /// Tests obtaining the block-level elements intercepting the full range of the following
    /// HTML string: <div>Hello <p>there</p> man!</div>
    ///
    /// The results should be:
    ///     - (node: div, range: (0...6))
    ///     - (node: p, range: (0...5))
    ///     - (node: div, range: (11...5))
    ///
    func testLowestBlockLevelElements2() {

        let textPart1 = "Hello "
        let textPart2 = "there"
        let textPart3 = " man!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)
        let textNode3 = TextNode(text: textPart3)

        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode2])
        let div = ElementNode(name: "div", attributes: [], children: [textNode1, paragraph, textNode3])

        let results = div.lowestBlockLevelElements(intersectingRange: div.range())

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].element.name, "div")
        XCTAssertEqual(results[0].intersection.location, 0)
        XCTAssertEqual(results[0].intersection.length, 6)
        XCTAssertEqual(results[1].element.name, "p")
        XCTAssertEqual(results[1].intersection.location, 0)
        XCTAssertEqual(results[1].intersection.length, 5)
        XCTAssertEqual(results[2].element.name, "div")
        XCTAssertEqual(results[2].intersection.location, 11)
        XCTAssertEqual(results[2].intersection.length, 5)
    }


    /// Tests obtaining the block-level elements intercepting the full range of the following
    ///
    /// HTML string: <div><p>Hello </p>there!</div>
    ///
    /// The results should be:
    ///     - (node: p, range: (0...6))
    ///     - (node: div, range: (6...6))
    ///
    func testLowestBlockLevelElements3() {

        let textPart1 = "Hello "
        let textPart2 = "there!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1])
        let div = ElementNode(name: "div", attributes: [], children: [paragraph, textNode2])

        let results = div.lowestBlockLevelElements(intersectingRange: div.range())

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].element.name, "p")
        XCTAssertEqual(results[0].intersection.location, 0)
        XCTAssertEqual(results[0].intersection.length, 6)
        XCTAssertEqual(results[1].element.name, "div")
        XCTAssertEqual(results[1].intersection.location, 6)
        XCTAssertEqual(results[1].intersection.length, 6)
    }

    /// Tests wrapping child nodes intersecting a certain range in a new `b` node.
    ///
    /// HTML String: <div><em>Hello </em>there!</div>
    /// Wrap range: (0...6)
    ///
    /// The result should be: <div><b><em>Hello </em></b>there!</div>
    ///
    func testWrapChildrenInNewBNode1() {

        let boldNodeName = "b"
        let range = NSRange(location: 0, length: 6)

        let textPart1 = "Hello "
        let textPart2 = "there!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let em = ElementNode(name: "em", attributes: [], children: [textNode1])
        let div = ElementNode(name: "div", attributes: [], children: [em, textNode2])

        div.wrapChildren(intersectingRange: range, inNodeNamed: boldNodeName, withAttributes: [], equivalentElementNames: [])

        XCTAssertEqual(div.children.count, 2)
        XCTAssertEqual(div.children[1], textNode2)

        guard let boldNode = div.children[0] as? ElementNode else {
            XCTFail("Expected a bold node here.")
            return
        }

        XCTAssertEqual(boldNode.name, boldNodeName)
        XCTAssertEqual(boldNode.children.count, 1)
        XCTAssertEqual(boldNode.children[0], em)

        XCTAssertEqual(em.children.count, 1)
        XCTAssertEqual(em.children[0], textNode1)
    }

    /// Tests wrapping child nodes intersecting a certain range in a new `b` node.
    ///
    /// HTML String: <div><em>Hello </em>there!</div>
    /// Wrap range: (0...6)
    ///
    /// The result should be: <div><b><em>Hello </em></b>there!</div>
    ///
    func testWrapChildrenInNewBNode2() {

        let boldNodeName = "b"
        let range = NSRange(location: 0, length: 6)

        let textPart1 = "Hello "
        let textPart2 = "there!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let em = ElementNode(name: "em", attributes: [], children: [textNode1])
        let div = ElementNode(name: "div", attributes: [], children: [em, textNode2])

        div.wrapChildren(intersectingRange: range, inNodeNamed: boldNodeName, withAttributes: [], equivalentElementNames: [])

        XCTAssertEqual(div.children.count, 2)
        XCTAssertEqual(div.children[1], textNode2)

        guard let boldNode = div.children[0] as? ElementNode else {
            XCTFail("Expected a bold node here.")
            return
        }

        XCTAssertEqual(boldNode.name, boldNodeName)
        XCTAssertEqual(boldNode.children.count, 1)
        XCTAssertEqual(boldNode.children[0], em)

        XCTAssertEqual(em.children.count, 1)
        XCTAssertEqual(em.children[0], textNode1)
    }


    /// Tests wrapping child nodes intersecting a certain range in a new `b` node.
    ///
    /// HTML String: <div><em>Hello </em><u>there!</u></div>
    /// Wrap range: full text range / full div node range
    ///
    /// The result should be: <div><b><em>Hello </em><u>there!</u></b></div>
    ///
    func testWrapChildrenInNewBNode3() {

        let boldNodeName = "b"

        let textPart1 = "Hello "
        let textPart2 = "there!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let em = ElementNode(name: "em", attributes: [], children: [textNode1])
        let underline = ElementNode(name: "u", attributes: [], children: [textNode2])
        let div = ElementNode(name: "div", attributes: [], children: [em, underline])

        div.wrapChildren(intersectingRange: div.range(), inNodeNamed: boldNodeName, withAttributes: [], equivalentElementNames: [])

        XCTAssertEqual(div.children.count, 1)

        guard let boldNode = div.children[0] as? ElementNode else {
            XCTFail("Expected a bold node here.")
            return
        }

        XCTAssertEqual(boldNode.name, boldNodeName)
        XCTAssertEqual(boldNode.children.count, 2)
        XCTAssertEqual(boldNode.children[0], em)
        XCTAssertEqual(boldNode.children[1], underline)

        XCTAssertEqual(em.children.count, 1)
        XCTAssertEqual(em.children[0], textNode1)

        XCTAssertEqual(underline.children.count, 1)
        XCTAssertEqual(underline.children[0], textNode2)
    }


    /// Tests wrapping child nodes intersecting a certain range in a new `b` node.
    ///
    /// HTML String: <div><em>Hello </em><u>there!</u></div>
    /// Wrap range: (2...8)
    ///
    /// The result should be: <div><em>He</em><b><em>llo </em><u>ther</u></b><u>e!</u></div>
    ///
    func testWrapChildrenInNewBNode4() {

        let boldNodeName = "b"

        let textPart1 = "Hello "
        let textPart2 = "there!"

        let textNode1 = TextNode(text: textPart1)
        let textNode2 = TextNode(text: textPart2)

        let em = ElementNode(name: "em", attributes: [], children: [textNode1])
        let underline = ElementNode(name: "u", attributes: [], children: [textNode2])
        let div = ElementNode(name: "div", attributes: [], children: [em, underline])

        let range = NSRange(location: 2, length: 8)

        div.wrapChildren(intersectingRange: range, inNodeNamed: boldNodeName, withAttributes: [], equivalentElementNames: [])

        XCTAssertEqual(div.children.count, 3)

        XCTAssertEqual(div.children[0].name, "em")
        XCTAssertEqual(div.children[0].length(), 2)
        XCTAssertEqual(div.children[2].name, "u")
        XCTAssertEqual(div.children[2].length(), 2)

        guard let boldNode = div.children[1] as? ElementNode else {
            XCTFail("Expected a bold node here.")
            return
        }

        XCTAssertEqual(boldNode.name, boldNodeName)
        XCTAssertEqual(boldNode.children.count, 2)
        XCTAssertEqual(boldNode.children[0], em)
        XCTAssertEqual(boldNode.children[1], underline)

        XCTAssertEqual(em.children.count, 1)
        XCTAssertEqual(em.children[0].length(), 4)

        XCTAssertEqual(underline.children.count, 1)
        XCTAssertEqual(underline.children[0].length(), 4)
    }
    
    /// Tests that wrapping a range in a node already present in that range works.
    ///
    /// HTML String: <div><b>Hello there</b></div>
    /// Wrap range: (0...11)
    ///
    /// Expected results:
    ///     - The output should match the input.
    ///
    func testWrapChildrenIntersectingRangeWithEquivalentNodeNames1() {
        let textNode = TextNode(text: "Hello there")
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode])
        let divNode = ElementNode(name: "div", attributes: [], children: [boldNode])
        
        let range = NSRange(location: 0, length: 11)
        
        divNode.wrapChildren(intersectingRange: range, inNodeNamed: "b", withAttributes: [], equivalentElementNames: [])
        
        XCTAssertEqual(divNode.children.count, 1)
        
        guard let newBoldNode = divNode.children[0] as? ElementNode
            where newBoldNode.name == "b" else {
                
                XCTFail("Expected a bold node")
                return
        }
        
        XCTAssertEqual(newBoldNode.children.count, 1)
        XCTAssertNotNil(newBoldNode.children[0] as? TextNode)
        XCTAssertEqual(boldNode.text(), newBoldNode.text())
    }

    /// Tests `childNodes(intersectingRange:)` with a zero-length range.
    ///
    /// Input HTML: <p>This is a test string.</p>
    /// Range: (5...0)
    ///
    /// Expected results:
    ///     - should find 1 matching child node (the text node)
    ///     - the range should be unchanged
    ///
    func testChildNodesIntersectingRange1() {
        let textNode = TextNode(text: "This is a test string.")
        let rangeLocation = 5
        XCTAssert(rangeLocation < textNode.length(),
                  "For this text we need to make sure the range location is inside the test node.")

        let range = NSRange(location: rangeLocation, length: 0)
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode])

        let childrenAndRanges = paragraph.childNodes(intersectingRange: range)

        guard childrenAndRanges.count == 1 else {
            XCTFail("Expected 1 child.")
            return
        }

        XCTAssertEqual(childrenAndRanges[0].child, textNode)
        XCTAssert(NSEqualRanges(childrenAndRanges[0].intersection, range))
    }


    /// Tests `childNodes(intersectingRange:)` with a zero-length range.
    ///
    /// Input HTML: <p>This is a test string.</p>
    /// Range: (0...0)
    ///
    /// Expected results:
    ///     - should find 1 matching child node (the text node)
    ///     - the range should be unchanged
    ///
    func testChildNodesIntersectingRange2() {
        let textNode = TextNode(text: "This is a test string.")
        let rangeLocation = 0
        XCTAssert(rangeLocation < textNode.length(),
                  "For this text we need to make sure the range location is inside the test node.")

        let range = NSRange(location: rangeLocation, length: 0)
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode])

        let childrenAndRanges = paragraph.childNodes(intersectingRange: range)

        guard childrenAndRanges.count == 1 else {
            XCTFail("Expected 1 child.")
            return
        }

        XCTAssertEqual(childrenAndRanges[0].child, textNode)
        XCTAssert(NSEqualRanges(childrenAndRanges[0].intersection, range))
    }

    /// Tests `childNodes(intersectingRange:)` with a zero-length range.
    ///
    /// Input HTML: <p><b>Hello</b><b>Hello again!</b></p>
    /// Prefer left node: true
    /// Range: (5...0)
    ///
    /// Expected results:
    ///     - should find 1 matching child node (the first bold node)
    ///     - the range should be unchanged
    ///
    func testChildNodesIntersectingRange3() {

        let textNode1 = TextNode(text: "Hello")
        let textNode2 = TextNode(text: "Hello again!")

        let rangeLocation = 5
        XCTAssert(rangeLocation == textNode1.length(),
                  "For this text we need to make sure the range location is inside the test node.")

        let range = NSRange(location: rangeLocation, length: 0)

        let bold1 = ElementNode(name: "b", attributes: [], children: [textNode1])
        let bold2 = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [bold1, bold2])

        let childrenAndRanges = paragraph.childNodes(intersectingRange: range, preferLeftNode: true)

        guard childrenAndRanges.count == 1 else {
            XCTFail("Expected 1 child.")
            return
        }

        XCTAssertEqual(childrenAndRanges[0].child, bold1)
        XCTAssert(NSEqualRanges(childrenAndRanges[0].intersection, range))
    }

    /// Tests `childNodes(intersectingRange:)` with a zero-length range.
    ///
    /// Input HTML: <p><b>Hello</b><b>Hello again!</b></p>
    /// Prefer left node: false
    /// Range: (5...0)
    ///
    /// Expected results:
    ///     - should find 1 matching child node (the second bold node)
    ///     - the range should be unchanged
    ///
    func testChildNodesIntersectingRange4() {

        let textNode1 = TextNode(text: "Hello")
        let textNode2 = TextNode(text: "Hello again!")

        let rangeLocation = 5
        XCTAssert(rangeLocation == textNode1.length(),
                  "For this text we need to make sure the range location is inside the test node.")

        let range = NSRange(location: rangeLocation, length: 0)

        let bold1 = ElementNode(name: "b", attributes: [], children: [textNode1])
        let bold2 = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [bold1, bold2])

        let childrenAndRanges = paragraph.childNodes(intersectingRange: range, preferLeftNode: false)

        guard childrenAndRanges.count == 1 else {
            XCTFail("Expected 1 child.")
            return
        }

        XCTAssertEqual(childrenAndRanges[0].child, bold2)
        XCTAssert(NSEqualRanges(childrenAndRanges[0].intersection, NSRange(location: 0, length: 0)))
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p><b>Hello1</b><b>Hello2</b></p>
    /// String: "---"
    /// Index: 0
    ///
    /// Expected results:
    ///     - Output should be: <p>---<b>Hello1</b><b>Hello2</b></p>
    ///
    func testInsertStringAt1() {
        let textNode1 = TextNode(text: "Hello1")
        let textNode2 = TextNode(text: "Hello2")
        let boldNode1 = ElementNode(name: "b", attributes: [], children: [textNode1])
        let boldNode2 = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [boldNode1, boldNode2])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 0)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let newTextNode = paragraph.children[0] as? TextNode
            where newTextNode.text() == textToInsert else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[1], boldNode1)
        XCTAssertEqual(paragraph.children[2], boldNode2)
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p><b>Hello1</b><b>Hello2</b></p>
    /// String: "---"
    /// Index: 1
    ///
    /// Expected results:
    ///     - Output should be: <p><b>Hello1</b>---<b>Hello2</b></p>
    ///
    func testInsertStringAt2() {
        let textNode1 = TextNode(text: "Hello1")
        let textNode2 = TextNode(text: "Hello2")
        let boldNode1 = ElementNode(name: "b", attributes: [], children: [textNode1])
        let boldNode2 = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [boldNode1, boldNode2])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 1)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let newTextNode = paragraph.children[1] as? TextNode
            where newTextNode.text() == textToInsert else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[0], boldNode1)
        XCTAssertEqual(paragraph.children[2], boldNode2)
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p><b>Hello1</b><b>Hello2</b></p>
    /// String: "---"
    /// Index: 2
    ///
    /// Expected results:
    ///     - Output should be: <p><b>Hello1</b><b>Hello2</b>---</p>
    ///
    func testInsertStringAt3() {
        let textNode1 = TextNode(text: "Hello1")
        let textNode2 = TextNode(text: "Hello2")
        let boldNode1 = ElementNode(name: "b", attributes: [], children: [textNode1])
        let boldNode2 = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [boldNode1, boldNode2])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 2)

        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let newTextNode = paragraph.children[2] as? TextNode
            where newTextNode.text() == textToInsert else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[0], boldNode1)
        XCTAssertEqual(paragraph.children[1], boldNode2)
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p>Hello1<b>Hello2</b>Hello3</p>
    /// String: "---"
    /// Index: 0
    ///
    /// Expected results:
    ///     - Output should be: <p>---Hello1<b>Hello2</b>Hello3</p>
    ///     - The string should be attached to the adjacent TextNode.
    ///
    func testInsertStringAt4() {
        
        let adjacentText = "Hello1"
        
        let textNode1 = TextNode(text: adjacentText)
        let textNode2 = TextNode(text: "Hello2")
        let textNode3 = TextNode(text: "Hello3")
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1, boldNode, textNode3])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 0)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let textNode = paragraph.children[0] as? TextNode
            where textNode.text() == "\(textToInsert)\(adjacentText)" else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[1], boldNode)
        XCTAssertEqual(paragraph.children[2], textNode3)
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p>Hello1<b>Hello2</b>Hello3</p>
    /// String: "---"
    /// Index: 1
    ///
    /// Expected results:
    ///     - Output should be: <p>Hello1---<b>Hello2</b>Hello3</p>
    ///     - The string should be attached to the adjacent TextNode.
    ///
    func testInsertStringAt5() {
        
        let adjacentText = "Hello1"
        
        let textNode1 = TextNode(text: adjacentText)
        let textNode2 = TextNode(text: "Hello2")
        let textNode3 = TextNode(text: "Hello3")
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1, boldNode, textNode3])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 1)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let textNode = paragraph.children[0] as? TextNode
            where textNode.text() == "\(adjacentText)\(textToInsert)" else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[1], boldNode)
        XCTAssertEqual(paragraph.children[2], textNode3)
    }
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p>Hello1<b>Hello2</b>Hello3</p>
    /// String: "---"
    /// Index: 2
    ///
    /// Expected results:
    ///     - Output should be: <p>Hello1<b>Hello2</b>---Hello3</p>
    ///     - The string should be attached to the adjacent TextNode.
    ///
    func testInsertStringAt6() {
        
        let adjacentText = "Hello3"
        
        let textNode1 = TextNode(text: "Hello1")
        let textNode2 = TextNode(text: "Hello2")
        let textNode3 = TextNode(text: adjacentText)
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1, boldNode, textNode3])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 2)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let textNode = paragraph.children[2] as? TextNode
            where textNode.text() == "\(textToInsert)\(adjacentText)" else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[0], textNode1)
        XCTAssertEqual(paragraph.children[1], boldNode)
    }
    
    
    /// Tests `insert(string: String, at index: Int)`.
    ///
    /// Input HTML: <p>Hello1<b>Hello2</b>Hello3</p>
    /// String: "---"
    /// Index: 3
    ///
    /// Expected results:
    ///     - Output should be: <p>Hello1<b>Hello2</b>Hello3---</p>
    ///     - The string should be attached to the adjacent TextNode.
    ///
    func testInsertStringAt7() {
        
        let adjacentText = "Hello3"
        
        let textNode1 = TextNode(text: "Hello1")
        let textNode2 = TextNode(text: "Hello2")
        let textNode3 = TextNode(text: adjacentText)
        let boldNode = ElementNode(name: "b", attributes: [], children: [textNode2])
        let paragraph = ElementNode(name: "p", attributes: [], children: [textNode1, boldNode, textNode3])
        
        let textToInsert = "---"
        
        paragraph.insert(textToInsert, at: 3)
        
        XCTAssertEqual(paragraph.children.count, 3)
        
        guard let textNode = paragraph.children[2] as? TextNode
            where textNode.text() == "\(adjacentText)\(textToInsert)" else {
                XCTFail("Expected a text node here with the inserted text.")
                return
        }
        
        XCTAssertEqual(paragraph.children[0], textNode1)
        XCTAssertEqual(paragraph.children[1], boldNode)
    }

    /// Tests `replaceCharacters(inRange:withString:)`.
    ///
    /// Input HTML: `<p>Click on this <a href="http://www.wordpress.com">link</a></p>`
    /// - Range: the range of the full contents of the `<a>` node.
    /// - New String: "link!"
    /// - Inherit Style: true
    ///
    /// Expected results:
    /// - Output: `<p>Click on this <a href="http://www.wordpress.com">link!</a></p>`
    ///
    func testReplaceCharactersInRangeWithString() {
        let linkText = TextNode(text: "link")
        let linkElement = ElementNode(name: "a", attributes: [], children: [linkText])
        let preLinkText = TextNode(text: "Click on this ")
        let paragraph = ElementNode(name: "p", attributes: [], children: [preLinkText, linkElement])
        
        let range = NSRange(location: 14, length: 4)
        let newString = "link!"
        
        paragraph.replaceCharacters(inRange: range, withString: newString, inheritStyle: true)
        
        XCTAssertEqual(paragraph.children.count, 2)
        XCTAssertEqual(paragraph.children[0], preLinkText)
        
        guard let link = paragraph.children[1] as? ElementNode
            where link.name == "a" else {
                
            XCTFail("Expected a link element node")
                return
        }
        
        XCTAssertEqual(link.children.count, 1)
        XCTAssertEqual(link.text(), newString)
    }
    
    /// Tests `replaceCharacters(inRange:withString:)`.
    ///
    /// Input HTML: `<p>Click on this <a href="http://www.wordpress.com">link</a></p>`
    /// - Range: the range of the full contents of the `<a>` node.
    /// - New String: "link!"
    /// - Inherit Style: false
    ///
    /// Expected results:
    /// - Output: `<p>Click on this link!</p>`
    ///
    func testReplaceCharactersInRangeWithString2() {
        let text1 = "Click on this "
        let text2 = "link"
        let linkText = TextNode(text: text2)
        let linkElement = ElementNode(name: "a", attributes: [], children: [linkText])
        let preLinkText = TextNode(text: text1)
        let paragraph = ElementNode(name: "p", attributes: [], children: [preLinkText, linkElement])
        
        let range = NSRange(location: 14, length: 4)
        let newString = "link!"
        let finalText = "\(text1)\(text2)!"
        
        paragraph.replaceCharacters(inRange: range, withString: newString, inheritStyle: false)
        
        XCTAssertEqual(paragraph.children.count, 1)
        
        guard let textNode = paragraph.children[0] as? TextNode
            where textNode.text() == finalText else {
                
                XCTFail("Expected a text node, with the full text.")
                return
        }
    }
    
    /// Tests `replaceCharacters(inRange:withString:)`.
    ///
    /// Input HTML: `<div><p>Click on this <a href="http://www.wordpress.com">link</a></p></div>`
    /// - Range: the range of the full contents of the `<a>` node.
    /// - New String: "link!"
    /// - Inherit Style: false
    ///
    /// Expected results:
    /// - Output: `<div><p>Click on this link!</p></div>`
    ///
    func testReplaceCharactersInRangeWithString3() {
        let text1 = "Click on this "
        let text2 = "link"
        let linkText = TextNode(text: text2)
        let linkElement = ElementNode(name: "a", attributes: [], children: [linkText])
        let preLinkText = TextNode(text: text1)
        let paragraph = ElementNode(name: "p", attributes: [], children: [preLinkText, linkElement])
        let div = ElementNode(name: "div", attributes: [], children: [paragraph])
        
        let range = NSRange(location: 14, length: 4)
        let newString = "link!"
        let finalText = "\(text1)\(text2)!"
        
        div.replaceCharacters(inRange: range, withString: newString, inheritStyle: false)
        
        XCTAssertEqual(div.children.count, 1)
        
        guard let newParagraph = div.children[0] as? ElementNode
            where newParagraph.name == "p" else {
                XCTFail("Expected a paragraph.")
                return
        }
        
        XCTAssertEqual(newParagraph.children.count, 1)
        
        guard let textNode = newParagraph.children[0] as? TextNode
            where textNode.text() == finalText else {
                
                XCTFail("Expected a text node, with the full text.")
                return
        }
    }

    /// Tests `replaceCharacters(inRange:withNodeName:withAttributes)`.
    ///
    /// Input HTML: `<p>Look at this photo:image.It's amazing</p>`
    /// - Range: the range of the image string.
    /// - New Node: <img>
    /// - Attributes:
    ///
    /// Expected results:
    /// - Output: `<p>Look at this photo:<img src="https://httpbin.org/image/jpeg.It's amazing" /></p>`
    ///
    func testReplaceCharactersInRangeWithNode() {
        let startText = "Look at this photo:"
        let middleText = "image"
        let endText = ".It's amazing"
        let paragraphText = TextNode(text: startText + middleText + endText)
        let paragraph = ElementNode(name: "p", attributes: [], children: [paragraphText])

        let range = NSRange(location: startText.characters.count, length: middleText.characters.count)
        let imgNodeName = "img"
        let imgSrc = "https://httpbin.org/image/jpeg"

        paragraph.replaceCharacters(inRange: range, withNodeNamed: imgNodeName, withAttributes:[Libxml2.StringAttribute(name:"src", value: imgSrc)])

        XCTAssertEqual(paragraph.children.count, 3)

        guard let startNode = paragraph.children[0] as? TextNode
            where startNode.text() == startText else {

                XCTFail("Expected a text node")
                return
        }

        guard let imgNode = paragraph.children[1] as? ElementNode
            where imgNode.name == imgNodeName else {

                XCTFail("Expected a img node")
                return
        }

        guard let endNode = paragraph.children[2] as? TextNode
            where endNode.text() == endText else {

                XCTFail("Expected a text node")
                return
        }

    }
}
