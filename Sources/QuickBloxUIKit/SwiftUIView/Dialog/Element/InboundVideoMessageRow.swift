//
//  InboundVideoMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog


public struct InboundVideoMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    @State private var isPlaying: Bool = false
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    @State public var userName: String?
    
    @State private var progress: CGFloat = 0.5
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
    }
    
    public var body: some View {
        
        HStack {
            
            if settings.isShowAvatar == true {
                VStack(spacing: settings.spacing) {
                    Spacer()
                    AvatarView(image: avatar,
                               height: settings.avatar.height,
                               isShow: settings.isShowAvatar)
                    .task {
                        do { avatar = try await message.avatar(size: CGSizeMake(settings.avatar.height, settings.avatar.height)) } catch { prettyLog(error) }
                    }
                }.padding(.leading)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                if settings.isShowName == true {
                    Text(userName ?? String(message.userId))
                        .foregroundColor(settings.name.foregroundColor)
                        .font(settings.name.font)
                        .padding(settings.inboundNamePadding)
                        .task {
                            do { userName = try await message.userName } catch { prettyLog(error) }
                        }
                }
                
                HStack(spacing: 8) {
                    
                    Button {
                        play()
                    } label: {
                        
                        ZStack(alignment: .center) {
                            if let image = fileTuple?.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: settings.attachmentSize.width,
                                           height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                    .padding(settings.inboundPadding(showName: settings.isShowName))
                                
                                settings.videoPlayBackground
                                    .frame(width: settings.imageIconSize.width,
                                           height: settings.imageIconSize.height)
                                    .cornerRadius(6)
                                
                                settings.play
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: settings.videoIconSize(isImage: true).width,
                                           height: settings.videoIconSize(isImage: true).height)
                                    .foregroundColor(settings.videoPlayForeground)
                                
                            } else {
                                
                                if progress > 0 {
                                    
                                    settings.progressBarBackground()
                                        .frame(width: settings.attachmentSize.width,
                                               height: settings.attachmentSize.height)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                        .padding(settings.inboundPadding(showName: settings.isShowName))
                                    
                                    SegmentedCircularProgressBar(progress: $progress)
                                    
                                } else {
                                    
                                    settings.inboundBackground
                                        .frame(width: settings.attachmentSize.width,
                                               height: settings.attachmentSize.height)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                        .padding(settings.inboundPadding(showName: settings.isShowName))
                                    
                                    settings.play
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: settings.videoIconSize(isImage: false).width,
                                               height: settings.videoIconSize(isImage: false).height)
                                        .foregroundColor(settings.inboundImageIconForeground)
                                }
                            }
                        }
                    }
                    .disabled(fileTuple?.url == nil)
                    .task {
                        do { fileTuple = try await message.file(size: settings.imageSize) } catch { prettyLog(error)}
                    }
                    
                    if settings.isShowTime == true {
                        VStack {
                            Spacer()
                            Text("\(message.date, formatter: settings.time.formatter)")
                                .foregroundColor(settings.time.foregroundColor)
                                .font(settings.time.font)
                                .padding(.bottom, settings.time.bottom)
                        }
                    }
                }
                .task {
                    do { fileTuple = try await message.file(size: nil) } catch { prettyLog(error)}
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
        
    }
    
    private func play() {
        guard let url = fileTuple?.url else { return }
        if isPlaying == true {
            onTap(.stop, nil, url)
        } else {
            onTap(.play, nil, url)
        }
    }
}

import QuickBloxData

struct InboundVideoMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_,_) in})
            .previewDisplayName("Video with Thumbnail")
            
            InboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_,_) in})
            .previewDisplayName("Video without Thumbnail")
            
            InboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_,_) in})
            .previewDisplayName("Video without Thumbnail")
            .preferredColorScheme(.dark)
            
            InboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_,_) in})
            .previewDisplayName("Video with Thumbnail")
            .preferredColorScheme(.dark)
        }
    }
}
