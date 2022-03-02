import MyMultiSig from "./MyMultiSig.cdc"
import FungibleToken from "./contracts/core/FungibleToken.cdc"
import NonFungibleToken from "./contracts/core/NonFungibleToken.cdc"

pub contract DAOTreasury {

  pub let TreasuryStoragePath: StoragePath
  pub let TreasuryPublicPath: PublicPath

  pub resource interface TreasuryPublic {
    pub fun proposeAction(intent: String, action: {MyMultiSig.Action})
    pub fun executeAction(actionUUID: UInt64)
    pub fun depositVault(vault: @FungibleToken.Vault)
    pub fun depositCollection(collection: @NonFungibleToken.Collection)
    pub fun borrowManagerPublic(): &MyMultiSig.Manager{MyMultiSig.ManagerPublic}
  }

  pub resource Treasury: MyMultiSig.MultiSign, TreasuryPublic {
    pub let multiSignManager: @MyMultiSig.Manager
    access(account) var vaults: @{String: FungibleToken.Vault}
    access(account) var collections: @{String: NonFungibleToken.Collection}

    // ------- Manager -------   
    pub fun proposeAction(intent: String, action: {MyMultiSig.Action}) {
      self.multiSignManager.createMultiSign(intent: intent, action: action)
    }

    pub fun executeAction(actionUUID: UInt64) {
      let action <- self.multiSignManager.executeAction(actionUUID: actionUUID)
      action.action.execute({"treasuryRef": &self as &Treasury})
      destroy action
    }

    pub fun borrowManager(): &MyMultiSig.Manager {
      return &self.multiSignManager as &MyMultiSig.Manager
    }

    pub fun borrowManagerPublic(): &MyMultiSig.Manager{MyMultiSig.ManagerPublic} {
      return &self.multiSignManager as &MyMultiSig.Manager{MyMultiSig.ManagerPublic}
    }

    // ------- Vaults ------- 
    pub fun depositVault(vault: @FungibleToken.Vault) {
      let identifier = vault.getType().identifier
      if self.vaults[identifier] != nil {
        let ref = &self.vaults[identifier] as &FungibleToken.Vault
        ref.deposit(from: <- vault)
      } else {
        self.vaults[identifier] <-! vault
      }
    }

    pub fun borrowVault(identifier: String): &FungibleToken.Vault {
      return &self.vaults[identifier] as &FungibleToken.Vault
    }

    // ------- Collections ------- 
    pub fun depositCollection(collection: @NonFungibleToken.Collection) {
      self.collections[collection.getType().identifier] <-! collection
    }

    pub fun borrowCollection(identifier: String): &NonFungibleToken.Collection {
      return &self.collections[identifier] as &NonFungibleToken.Collection
    }

    init(_initialSigners: [Address]) {
      self.multiSignManager <- MyMultiSig.createMultiSigManager(signers: _initialSigners)
      self.vaults <- {}
      self.collections <- {}
    }

    destroy() {
      destroy self.multiSignManager
      destroy self.vaults
      destroy self.collections
    }
  }

  init() {
    self.TreasuryStoragePath = /storage/DAOTreasury
    self.TreasuryPublicPath = /public/DAOTreasury
  }

}