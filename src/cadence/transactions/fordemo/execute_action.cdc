import MyMultiSig from "../../MyMultiSig.cdc"

transaction(actionUUID: UInt64) {

  let Manager: &MyMultiSig.Manager
  
  prepare(signer: AuthAccount) {
    // borrow the manager
    self.Manager = signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001) ?? panic("Could not get the Manager.")
  }
  execute {
    let action <- self.Manager.executeAction(actionUUID: actionUUID)
    action.action.execute({})
    destroy action
  }
}