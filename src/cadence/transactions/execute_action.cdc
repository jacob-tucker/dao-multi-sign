import MyMultiSig from "../MyMultiSig.cdc"

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