import MyMultiSig from "./MyMultiSig.cdc"
import DAOTreasury from "./DAOTreasury.cdc"
import FungibleToken from "./contracts/core/FungibleToken.cdc"
// import MyMultiSig from 0x9b8f4facca188481
// import DAOTreasury from 0x9b8f4facca188481
// import FungibleToken from 0x9a0766d93b6608b7
pub contract TreasuryActions {

  // Transfers `amount` tokens from the treasury to `recipientVault`
  pub struct TransferToken: MyMultiSig.Action {
    pub let intent: String
    pub let recipientVault: Capability<&{FungibleToken.Receiver}>
    pub let amount: UFix64

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasury"]! as! &DAOTreasury.Treasury

      let vaultRef: &FungibleToken.Vault = treasuryRef.borrowVault(identifier: self.recipientVault.borrow()!.getType().identifier)
      let withdrawnTokens <- vaultRef.withdraw(amount: self.amount)
      self.recipientVault.borrow()!.deposit(from: <- withdrawnTokens)
    }

    init(_recipientVault: Capability<&{FungibleToken.Receiver}>, _amount: UFix64) {
      self.intent = "Transfer "
                        .concat(_amount.toString())
                        .concat(" ")
                        .concat(_recipientVault.getType().identifier)
                        .concat(" tokens from the treasury to ")
                        .concat(_recipientVault.borrow()!.owner!.address.toString())
      self.recipientVault = _recipientVault
      self.amount = _amount
    }
  }

  pub struct Test: MyMultiSig.Action {
    pub let intent: String
    pub let cap: Capability<&FungibleToken.Vault>

    pub fun execute(_ params: {String: AnyStruct}) {
      let tokens <- self.cap.borrow()!.withdraw(amount: 10.0)
      destroy tokens
    }

    init(_cap: Capability<&FungibleToken.Vault>) {
      self.intent = "Testing"
      self.cap = _cap
    }
  }
}