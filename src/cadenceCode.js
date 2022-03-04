export const createTreasury = `
import DAOTreasury from 0xMS

// 1.
transaction(initialSigners: [Address]) {
  
  prepare(signer: AuthAccount) {
    signer.save(<- DAOTreasury.createTreasury(initialSigners: initialSigners), to: DAOTreasury.TreasuryStoragePath)
    signer.link<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>(DAOTreasury.TreasuryPublicPath, target: DAOTreasury.TreasuryStoragePath)
  }
  execute {
    
  }
}
`;

export const getIntents = `
import DAOTreasury from 0xMS

pub fun main(treasuryAddr: Address): {UInt64: String} {
  let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

  return treasury.borrowManagerPublic().getIntents()
}
`

export const getIntent = `
import DAOTreasury from 0xMS

pub fun main(treasuryAddr: Address, actionUUID: UInt64): String {
  let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

  let manager = treasury.borrowManagerPublic()
  let action = manager.borrowAction(actionUUID: actionUUID)
  return action.intent
}
`

export const signAction = `
import DAOTreasury from 0xMS

// 4.
transaction(treasuryAddr: Address, actionUUID: UInt64, message: String, keyIds: [Int], signatures: [String], signatureBlock: UInt64) {
  
  prepare(signer: AuthAccount) {
    let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

    let manager = treasury.borrowManagerPublic()
    let action = manager.borrowAction(actionUUID: actionUUID)
    action.verifySignature(acctAddress: signer.address, message: message, keyIds: keyIds, signatures: signatures, signatureBlock: signatureBlock)
  }
  execute {
    
  }
}
`;

export const executeAction = `
import DAOTreasury from 0xMS

// 5.
transaction(treasuryAddr: Address, actionUUID: UInt64) {
  
  prepare(signer: AuthAccount) {
    let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")
                  
    treasury.executeAction(actionUUID: actionUUID)
  }
  execute {

  }
}
`

export const proposeAction = `
import TreasuryActions from 0xMS
import DAOTreasury from 0xMS
import FungibleToken from 0xFungibleToken

// An example of proposing an action.
//
// Proposed ACTION: Transfer 'amount' FlowToken from the DAOTreasury
// at 'treasuryAddr' to 'recipientAddr'

// 3.
transaction(treasuryAddr: Address, recipientAddr: Address, amount: UFix64) {
  
  prepare(signer: AuthAccount) {
    let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

    let recipientVault = getAccount(recipientAddr).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    let action = TreasuryActions.TransferToken(_recipientVault: recipientVault, _amount: amount)
    treasury.proposeAction(action: action)
  }
  execute {
    
  }
}
`

export const addSigner = `
import DAOTreasury from 0xMS

// 2.
transaction(additionalSigner: Address) {
  
  prepare(signer: AuthAccount) {
    let treasury = signer.borrow<&DAOTreasury.Treasury>(from: DAOTreasury.TreasuryStoragePath)
                    ?? panic("Could not borrow the DAOTreasury")
    let manager = treasury.borrowManager()
    manager.addSigner(signer: additionalSigner)
  }
  execute {
    
  }
}
`

export const getVaultBalance = `
import DAOTreasury from 0xMS
import FungibleToken from 0xFungibleToken

pub fun main(treasuryAddr: Address): UFix64 {
  let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

  let identifier: String = "A.7e60df042a9c0868.FlowToken.Vault"
  let ref: &FungibleToken.Vault = treasury.borrowVaultPublic(identifier: identifier)
  let vault = ref as &FungibleToken.Vault{FungibleToken.Balance}
  return vault.balance
}
`

export const fundTreasury = `
import DAOTreasury from 0xMS
import FungibleToken from 0xFungibleToken

// 5.
transaction(treasuryAddr: Address, amount: UFix64) {
  
  prepare(signer: AuthAccount) {
    let vault = signer.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)!
    let tokens <- vault.withdraw(amount: amount)
    let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

    
    treasury.depositVault(vault: <- tokens)
  }
  execute {

  }
}
`

export const getTreasuryIdentifiers = `
import DAOTreasury from 0xMS

pub fun main(treasuryAddr: Address): [[String]] {
  let treasury = getAccount(treasuryAddr).getCapability(DAOTreasury.TreasuryPublicPath)
                    .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                    ?? panic("A DAOTreasury doesn't exist here.")

  let answer: [[String]] = []
  answer.append(treasury.getVaultIdentifiers())
  answer.append(treasury.getCollectionIdentifiers())
  return answer
}
`