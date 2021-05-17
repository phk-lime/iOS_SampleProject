//
//  KeychainItem.swift
//  Authentication
//
//  Created by limefriends on 2021/05/04.
//

import Foundation

struct KeychainItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
    
    // MARK: Properties
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readItem() throws -> String {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         서비스, ​​계정 및 액세스 그룹과 일치하는 항목을 찾는 쿼리를 작성
         */
        var query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        // 쿼리와 일치하는 기존 키 체인 항목 패치
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        // 반환 상태를 확인하고 적절한 경우 오류를 발생시킵니다.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        // Parse the password string from the query result.
        // 쿼리 결과에서 암호 문자열을 구문 분석합니다.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    func saveItem(_ password: String) throws {
        // Encode the password into an Data object.
        // 암호를 Data 개체로 인코딩합니다.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            // 키 체인에 있는 기존 항목 확인
            try _ = readItem()
            
            // Update the existing item with the new password.
            // 새 비밀번호로 기존 항목을 업데이트
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            // 예기치 않은 상태가 반환되면 오류를 발생시킵니다.
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             키 체인에 암호 없음, 새로운 키 체인 항목으로 저장할 dictionary 생성
             */
            var newItem = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            // 키 체인에 새 항목 추가
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            // 예기치 않은 상태가 반환되면 오류 발생
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        // 키 체인에서 기존 항목 삭제
        let query = KeychainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        // 예기치 않은 상태가 반환되면 오류 발생
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
    /*
     For the purpose of this demo app, the user identifier will be stored in the device keychain.
     You should store the user identifier in your account management system.
     이 데모 앱의 목적을 위해 사용자 식별자는 장치 키 체인에 저장됩니다.
     계정 관리 시스템에 사용자 식별자를 저장해야합니다.
     */
    static var currentUserIdentifier: String {
        do {
            let storedIdentifier = try KeychainItem(service: "Sample.Authentication", account: "userIdentifier").readItem()
            return storedIdentifier
        } catch {
            return ""
        }
    }
    
    static func deleteUserIdentifierFromKeychain() {
        do {
            try KeychainItem(service: "Sample.Authentication", account: "userIdentifier").deleteItem()
        } catch {
            print("Unable to delete userIdentifier from keychain")
        }
    }
}
