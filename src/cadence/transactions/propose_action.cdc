import TreasuryActions from "../TreasuryActions.cdc"
import DAOTreasury from "../DAOTreasury.cdc"
import FungibleToken from "../contracts/core/FungibleToken.cdc"

// An example of proposing an action.
//
// ACTION: Transfer `amount` FlowToken from the DAOTreasury
// at `treasuryAddr` to `recipientAddr`
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