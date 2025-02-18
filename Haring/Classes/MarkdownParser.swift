//
//  MarkdownParser.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//

import UIKit

open class MarkdownParser {

    // MARK: Element Arrays
    fileprivate var escapingElements: [MarkdownElement]
    fileprivate var defaultElements: [MarkdownElement]
    fileprivate var unescapingElements: [MarkdownElement]

    open var customElements: [MarkdownElement]

    // MARK: Basic Elements
    public let header: MarkdownHeader
    public let list: MarkdownList
    public let quote: MarkdownQuote
    public let link: MarkdownLink
    public let automaticLink: MarkdownAutomaticLink
    public let bold: MarkdownBold
    public let italic: MarkdownItalic
    public let code: MarkdownCode

    // MARK: Escaping Elements
    fileprivate var codeEscaping = MarkdownCodeEscaping()
    fileprivate var escaping = MarkdownEscaping()
    fileprivate var unescaping = MarkdownUnescaping()

    // MARK: Configuration
    /// Enables or disables detection of URLs even without Markdown format
    open var automaticLinkDetectionEnabled: Bool = true
    open var font: UIFont
    open var color: UIColor

    // MARK: Initializer
    public init(font: UIFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                color: UIColor = UIColor.black,
                automaticLinkDetectionEnabled: Bool = true,
                customElements: [MarkdownElement] = []) {
        self.font = font
        self.color = color

        header = MarkdownHeader(font: font)
        list = MarkdownList(font: font)
        quote = MarkdownQuote(font: font)
        link = MarkdownLink(font: font)
        automaticLink = MarkdownAutomaticLink(font: font)
        bold = MarkdownBold(font: font)
        italic = MarkdownItalic(font: font)
        code = MarkdownCode(font: font)

        self.automaticLinkDetectionEnabled = automaticLinkDetectionEnabled
        self.escapingElements = [codeEscaping, escaping]
        self.defaultElements = [header, list, quote, link, automaticLink, bold, italic]
        self.unescapingElements = [code, unescaping]
        self.customElements = customElements
    }

    // MARK: Element Extensibility
    open func addCustomElement(_ element: MarkdownElement) {
        customElements.append(element)
    }

    open func removeCustomElement(_ element: MarkdownElement) {
        guard let index = customElements.firstIndex(where: { someElement -> Bool in
            return element === someElement
        }) else {
            return
        }
        customElements.remove(at: index)
    }

    // MARK: Parsing
    open func parse(_ markdown: String) -> NSAttributedString {
        return parse(NSAttributedString(string: markdown))
    }

    open func parse(_ markdown: NSAttributedString) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: markdown)
        attributedString.addAttribute(NSAttributedString.Key.font, value: font,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color,
                                      range: NSRange(location: 0, length: attributedString.length))
        var elements: [MarkdownElement] = escapingElements
        elements.append(contentsOf: defaultElements)
        elements.append(contentsOf: customElements)
        elements.append(contentsOf: unescapingElements)
        elements.forEach { element in
            if automaticLinkDetectionEnabled || type(of: element) != MarkdownAutomaticLink.self {
                element.parse(attributedString)
            }
        }
        return attributedString
    }

    /// A convenience function to update the `font` and `textColor` for all the built-in elements.
    open func update(font: UIFont, textColor: UIColor? = nil) {
        self.font = font
        header.font = font
        list.font = font
        quote.font = font
        link.font = font
        automaticLink.font = font
        bold.font = font.bold()
        italic.font = font.italic()
        code.font = font

        if let textColor = textColor {
            self.color = textColor
        }
    }
}
