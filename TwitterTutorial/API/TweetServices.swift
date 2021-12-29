//
//  TweetServices.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/28.
//

import Foundation
import Firebase
struct TweetService {
    static let shared = TweetService()
    
    // tweet upload : 작성한 유저, 시간, 좋아요, 리트윗, 글 내용 => Value에 저장
    func updateTweet(caption:String,completion: @escaping(Error?,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid":uid,
                      "timestamp":Int(NSDate().timeIntervalSince1970),
                      "likes":0,
                      "retweets":0,
                      "caption":caption] as [String:Any]
        
        // Tweet DB에 저장
        // 자동으로 unique id를 생성하고 거기에 value 업데이트
        REF_TWEETS.childByAutoId().updateChildValues(values,withCompletionBlock: completion)
    }
    
    // tweet 피드 업로드
    func fetchTweets(completion :@escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        // tweet DB에서 정보 조회.
        REF_TWEETS.observe(.childAdded) { snapshot in
            
            //tweet 정보 획득
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            // uid 정보로 유저 정보 조회
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
}
