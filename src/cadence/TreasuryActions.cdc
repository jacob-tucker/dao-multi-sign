import MyMultiSig from "./MyMultiSig.cdc"
import DAOTreasury from "./DAOTreasury.cdc"
import FungibleToken from "./contracts/core/FungibleToken.cdc"
import NonFungibleToken from "./contracts/core/NonFungibleToken.cdc"
// import MyMultiSig from 0x9b8f4facca188481
// import DAOTreasury from 0x9b8f4facca188481
// import FungibleToken from 0x9a0766d93b6608b7
pub contract TreasuryActions {

  // Transfers `amount` tokens from the treasury to `recipientVault`
  pub struct TransferToken: MyMultiSig.Action {
    pub let intent: String
    access(self) let recipientVault: Capability<&{FungibleToken.Receiver}>
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
                        .concat((_recipientVault.borrow()!.owner!.address as Address).toString())
      self.recipientVault = _recipientVault
      self.amount = _amount
    }
  }

  // Transfers an NFT from the treasury to `recipientCollection`
  pub struct TransferNFT: MyMultiSig.Action {
    pub let intent: String
    access(self) let recipientCollection: Capability<&{NonFungibleToken.CollectionPublic}>
    pub let withdrawID: UInt64

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasury"]! as! &DAOTreasury.Treasury

      let collectionRef: &NonFungibleToken.Collection = treasuryRef.borrowCollection(identifier: self.recipientCollection.borrow()!.getType().identifier)
      let nft <- collectionRef.withdraw(withdrawID: self.withdrawID)
      self.recipientCollection.borrow()!.deposit(token: <- nft)
    }

    init(_recipientCollection: Capability<&{NonFungibleToken.CollectionPublic}>, _nftID: UInt64) {
      self.intent = "Transfer a "
                        .concat(_recipientCollection.getType().identifier)
                        .concat(" NFT from the treasury to ")
                        .concat((_recipientCollection.borrow()!.owner!.address as Address).toString())
      self.recipientCollection = _recipientCollection
      self.withdrawID = _nftID
    }
  }

  // Add a new signer to the treasury
  pub struct AddSigner: MyMultiSig.Action {
    pub let signer: Address
    pub let intent: String

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasury"]! as! &DAOTreasury.Treasury

      let manager = treasuryRef.borrowManager()
      manager.addSigner(signer: self.signer)
    }

    init(_signer: Address) {
      self.signer = _signer
      self.intent = "Add ".concat((_signer as Address).toString()).concat(" as a signer to the Treasury.")
    }
  }

  // Add a new signer to the treasury
  pub struct RemoveSigner: MyMultiSig.Action {
    pub let signer: Address
    pub let intent: String

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasury"]! as! &DAOTreasury.Treasury

      let manager = treasuryRef.borrowManager()
      manager.removeSigner(signer: self.signer)
    }

    init(_signer: Address) {
      self.signer = _signer
      self.intent = "Remove ".concat((_signer as Address).toString()).concat(" as a signer to the Treasury.")
    }
  }

  // Update the threshold of signers
  pub struct UpdateThreshold: MyMultiSig.Action {
    pub let threshold: UInt64
    pub let intent: String

    pub fun execute(_ params: {String: AnyStruct}) {
      let treasuryRef: &DAOTreasury.Treasury = params["treasury"]! as! &DAOTreasury.Treasury

      let manager = treasuryRef.borrowManager()
      manager.updateThreshold(newThreshold: self.threshold)
    }

    init(_threshold: UInt64) {
      self.threshold = _threshold
      self.intent = "Update the threshold of signers needed to execute an action in the Treasury to ".concat(_threshold.toString())
    }
  }

  pub struct Test: MyMultiSig.Action {
    pub let intent: String
    access(self) let cap: Capability<&FungibleToken.Vault>

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