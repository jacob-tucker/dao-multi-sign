import DAOTreasury from "../DAOTreasury.cdc"

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