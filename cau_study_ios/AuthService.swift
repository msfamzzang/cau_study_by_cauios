//
//  AuthService.swift


import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            //firebase 5....HJ
            let uid = user?.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Couldn't Upload Image")
                    return
                } else {
                    print("Uploaded")
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if url != nil {
                            self.setUserInfomation(profileImageUrl: url!.absoluteString, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                        }
                    } )
                }
            })
        })
    }
    
    
    
    static func setUserInfomation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl, "introduceMyself": "자기소개를 입력해주세요"])
        onSuccess()
    }
    
    /*
     static func updateUserInfor(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
     
     Api.User.CURRENT_USER?.updateEmail(email, completion: { (error) in
     if error != nil {
     onError(error!.localizedDescription)
     }else {
     let uid = Api.User.CURRENT_USER?.uid
     let storageRef = FIRStorage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
     
     storageRef.put(imageData, metadata: nil, completion: { (metadata, error) in
     if error != nil {
     return
     }
     let profileImageUrl = metadata?.downloadURL()?.absoluteString
     
     self.updateDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, onSuccess: onSuccess, onError: onError)
     })
     }
     })
     
     }
     
     static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
     let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
     Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
     if error != nil {
     onError(error!.localizedDescription)
     } else {
     onSuccess()
     }
     
     })
     }
     */
}

