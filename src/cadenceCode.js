export const createManager = `
import MyMultiSig from 0xMS
import FlowToken from 0xFlowToken
import FungibleToken from 0xFungibleToken
import TreasuryActions from 0xMS

transaction(signers: [Address]) {
  
  prepare(signer: AuthAccount) {
    if signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001) == nil {
      // create new manager
      let manager <- MyMultiSig.createMultiSigManager(signers: signers)

      // create action to take
      signer.link<&FlowToken.Vault>(/private/DAOTreasury, target: /storage/flowTokenVault)
      let cap = signer.getCapability<&FungibleToken.Vault>(/private/DAOTreasury)

      manager.createMultiSign(intent: "Destroy Token", action: TreasuryActions.Test(_cap: cap))

      // save manager somewhere
      signer.save(<- manager, to: /storage/Manager001)
      signer.link<&MyMultiSig.Manager{MyMultiSig.ManagerPublic}>(/public/Manager001, target: /storage/Manager001)
    } else {
      let manager = signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001)!
      let cap = signer.getCapability<&FungibleToken.Vault>(/private/DAOTreasury)
      manager.createMultiSign(intent: "Destroy Token", action: TreasuryActions.Test(_cap: cap))
    }
  }
  execute {
    
  }
}
`;

export const getIntents = `
import MyMultiSig from 0xMS

pub fun main(account: Address): {UInt64: String} {
  let managerPublic = getAccount(account).getCapability(/public/Manager001)
                        .borrow<&MyMultiSig.Manager{MyMultiSig.ManagerPublic}>()
                        ?? panic("This account doesn't have a manager")
  return managerPublic.getIntents()
}
`

export const signAction = `
import MyMultiSig from 0xMS

transaction(actionUUID: UInt64, message: String, keyIds: [Int], signatures: [String], signatureBlock: UInt64) {
  
  prepare(signer: AuthAccount) {
    // borrow the manager
    let manager = signer.getCapability(/public/Manager001)
                    .borrow<&MyMultiSig.Manager{MyMultiSig.ManagerPublic}>()
                    ?? panic("Could not get the Manager.")

    let action = manager.borrowAction(actionUUID: actionUUID)

    action.verifySignature(acctAddress: signer.address, message: message, keyIds: keyIds, signatures: signatures, signatureBlock: signatureBlock)
  }
  execute {
    
  }
}
`;

export const executeAction = `
import MyMultiSig from 0xMS

transaction(actionUUID: UInt64) {
  
  prepare(signer: AuthAccount) {
    // borrow the manager
    let manager = signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001) ?? panic("Could not get the Manager.")

    let action <- manager.executeAction(actionUUID: actionUUID)
    action.action.execute({})
    destroy action
  }
  execute {
    
  }
}
`