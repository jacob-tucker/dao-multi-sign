import MyMultiSig from "../MyMultiSig.cdc"

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