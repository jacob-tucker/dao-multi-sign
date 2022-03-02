import MyMultiSig from "./MyMultiSig.cdc"
import DAOTreasury from "./DAOTreasury.cdc"
import FungibleToken from "./contracts/core/FungibleToken.cdc"
pub contract TreasuryActions {
  pub struct TransferToken: MyMultiSig.Action {
    pub let recipientVault: Capability<&FungibleToken.Vault{FungibleToken.Receiver}>
    pub let identifier: String
    pub let amount: UFix64

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasuryRef"] as! &DAOTreasury.Treasury

      let vaultRef: &FungibleToken.Vault = treasuryRef.borrowVault(identifier: self.identifier)
      let withdrawnTokens <- vaultRef.withdraw(amount: self.amount)
      self.recipientVault.borrow()!.deposit(from: <- withdrawnTokens)
    }

    init(_recipientVault: Capability<&FungibleToken.Vault{FungibleToken.Receiver}>, _type: Type, _amount: UFix64) {
      self.recipientVault = _recipientVault
      self.identifier = _type.identifier
      self.amount = _amount
    }
  }

  pub struct Test: MyMultiSig.Action {
    pub let cap: Capability<&FungibleToken.Vault>

    pub fun execute(_ params: {String: AnyStruct}) {
      let tokens <- self.cap.borrow()!.withdraw(amount: 10.0)
      destroy tokens
    }

    init(_cap: Capability<&FungibleToken.Vault>) {
      self.cap = _cap
    }
  }
}