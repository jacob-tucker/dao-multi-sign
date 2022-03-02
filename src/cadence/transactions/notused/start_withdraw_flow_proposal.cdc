import MyMultiSig from "../MyMultiSig.cdc"
import DAOTreasury from "../DAOTreasury.cdc"
import FlowToken from "../contracts/core/FlowToken.cdc"
import FungibleToken from "../contracts/core/FungibleToken.cdc"
import TreasuryActions from "../TreasuryActions.cdc"

transaction(treasuryAccount: Address, recipient: Address, amount: UFix64) {
  let Treasury: &DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}
  let RecipientVault: Capability<&FungibleToken.Vault{FungibleToken.Receiver}>
  prepare(signer: AuthAccount) {
    self.Treasury = getAccount(treasuryAccount).getCapability(/public/DAOTreasury)
                      .borrow<&DAOTreasury.Treasury{DAOTreasury.TreasuryPublic}>()
                      ?? panic("Could no find this DAOTreasury")
    self.RecipientVault = getAccount(recipient).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
  }
  execute {
    self.Treasury.proposeAction(
      intent: "Transfer `amount` FlowTokens out of the DAOTreasury owned by `treasuryAccount` to the `recipient`.", 
      action: TreasuryActions.TransferToken(_recipientVault: self.RecipientVault, _type: FlowToken.Vault.getType(), _amount: amount)
    ) 
  }
}