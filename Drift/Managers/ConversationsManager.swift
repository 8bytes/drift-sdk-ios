//
//  ConversationsManager.swift
//  Drift
//
//  Created by Brian McDonald on 08/06/2017.
//  Copyright © 2017 Drift. All rights reserved.
//

import Foundation

class ConversationsManager {
    
    class func checkForConversations(userId: Int) {
        DriftAPIManager.getEnrichedConversations(userId) { (result) in
            switch result {
            case .success(let conversations):
                let conversationsToShow = conversations.filter({$0.unreadMessages > 0})
                PresentationManager.sharedInstance.didRecieveNewMessages(conversationsToShow)
                for conversation in conversationsToShow {
                    print(conversation.conversation.preview)
                }
            case .failure(let error):
                LoggerManager.didRecieveError(error)
            }
        }
    }
}
