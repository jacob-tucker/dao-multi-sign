import MyMultiSig from "../../MyMultiSig.cdc";
import FlowToken from "../../contracts/core/FlowToken.cdc"
import FungibleToken from "../../contracts/core/FungibleToken.cdc"
import TreasuryActions from "../../TreasuryActions.cdc"

transaction(signers: [Address]) {
  
  prepare(signer: AuthAccount) {
    if signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001) == nil {
      // create new manager
      let manager <- MyMultiSig.createMultiSigManager(signers: signers)

      // create action to take
      signer.link<&FlowToken.Vault>(/private/DAOTreasury, target: /storage/flowTokenVault)
      let cap = signer.getCapability<&FungibleToken.Vault>(/private/DAOTreasury)

      manager.createMultiSign(action: TreasuryActions.Test(_cap: cap))

      // save manager somewhere
      signer.save(<- manager, to: /storage/Manager001)
      signer.link<&MyMultiSig.Manager{MyMultiSig.ManagerPublic}>(/public/Manager001, target: /storage/Manager001)
    } else {
      let manager = signer.borrow<&MyMultiSig.Manager>(from: /storage/Manager001)!
      let cap = signer.getCapability<&FungibleToken.Vault>(/private/DAOTreasury)
      manager.createMultiSign(action: TreasuryActions.Test(_cap: cap))
    }
  }
  execute {
    
  }
}