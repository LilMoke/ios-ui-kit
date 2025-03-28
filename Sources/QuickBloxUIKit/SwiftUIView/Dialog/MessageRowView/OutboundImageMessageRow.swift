//
//  OutboundImageMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundImageMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    private var fileTuple: (type: String, image: UIImage?, url: URL?)? = nil
    private var messagesActionState: MessageAction
    private var relatedTime: Date? = nil
    private var relatedStatus: MessageStatus? = nil
    private var isSelected = false
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                fileTuple: (type: String, image: UIImage?, url: URL?)? = nil,
                messagesActionState: MessageAction,
                relatedTime: Date?,
                relatedStatus: MessageStatus?,
                isSelected: Bool,
                onTap: @escaping (_ action: MessageAttachmentAction, _ url: URL?) -> Void,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.fileTuple = fileTuple
        self.messagesActionState = messagesActionState
        self.relatedTime = relatedTime
        self.relatedStatus = relatedStatus
        self.isSelected = isSelected
        self.onTap = onTap
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            HStack {
                
                if features.forward.enable == true,
                   messagesActionState == .forward {
                    Checkbox(isSelected: isSelected) {
                        onSelect(message, .forward)
                    }
                }
                
                Spacer(minLength: settings.outboundSpacer)
                
                if message.actionType == .none ||
                    message.actionType == .forward ||
                    message.actionType == .reply && message.relatedId.isEmpty == true {
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack(spacing: 3) {
                            
                            if let relatedStatus {
                                MessageRowStatus(status: relatedStatus)
                            } else {
                                MessageRowStatus(status: message.status)
                            }
                            
                            if let relatedTime {
                                MessageRowTime(date: relatedTime)
                            } else {
                                MessageRowTime(date: message.date)
                            }
                            
                        }.padding(.bottom, 2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    if message.actionType != .none, message.originSenderName != nil {
                        MessageRowName(message: message)
                    }
                    
                    if features.forward.enable == true,
                       messagesActionState == .forward {
                        messageContent()
                    } else {
                        messageContent()
                            .if(fileTuple?.image != nil, transform: { view in
                                view.customContextMenu (
                                    preview: messageContent(forPreview: true),
                                    preferredContentSize: CGSize(width: contentSize?.width ?? 0.0,
                                                                 height: contentSize?.height ?? 0.0)
                                ) {
                                    CustomContextMenuAction(title: settings.reply.title,
                                                            systemImage: settings.reply.systemImage ?? "", tintColor: settings.reply.color, flipped: UIImageAxis.none,
                                                            attributes: features.reply.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .reply)
                                    }
                                    CustomContextMenuAction(title: settings.forward.title,
                                                            systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                            attributes: features.forward.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .forward)
                                    }
                                }
                            })
                            .onTapGesture {
                                if fileTuple?.url != nil {
                                    open()
                                }
                            }
                    }
                }
            }
            .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
        }
    }
    
    @ViewBuilder
    private func messageContent(forPreview: Bool = false) -> some View {
        ZStack {
            if forPreview == true {
                if let image = fileTuple?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: settings.attachmentSize(isPortrait: image.size.height > image.size.width).width, height: settings.attachmentSize(isPortrait: image.size.height > image.size.width).height)
                        .fixedSize()
                        .clipped()
                }
            } else {
                if let image = fileTuple?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: settings.attachmentSize(isPortrait: image.size.height > image.size.width).width, height: settings.attachmentSize(isPortrait: image.size.height > image.size.width).height)
                        .fixedSize()
                        .clipped()
                } else {
                    settings.progressBarBackground()
                        .frame(width: settings.attachmentSize(isPortrait: true).width, height: settings.attachmentSize(isPortrait: true).height)
                    
                    SegmentedCircularBar(settings: settings.progressBar)
                }
            }
        }
        .cornerRadius(settings.attachmentRadius,
                      corners: features.forward.enable == true && message.actionType == .forward ||
                      message.actionType == .reply && message.relatedId.isEmpty == false ?
                      settings.outboundForwardCorners : settings.outboundCorners)
        .contentSize(onChange: { contentSize in
            self.contentSize = contentSize
        })
        .padding(settings.outboundPadding)
    }
    
    private func open() {
        guard let url = fileTuple?.url else { return }
        onTap(.open, url)
    }
}

import QuickBloxData

struct OutboundImageMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundImageMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date(),
                                                     actionType: .forward,
                                                     originSenderName: "Bob"),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            
            OutboundImageMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Out Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
