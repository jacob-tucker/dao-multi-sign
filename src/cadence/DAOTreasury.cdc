import MyMultiSig from "./MyMultiSig.cdc"
import FungibleToken from "./contracts/core/FungibleToken.cdc"
import NonFungibleToken from "./contracts/core/NonFungibleToken.cdc"
// import MetadataViews from "./contracts/core/MetadataViews.cdc"

pub contract DAOTreasury {

  pub let TreasuryStoragePath: StoragePath
  pub let TreasuryPublicPath: PublicPath

  pub resource interface TreasuryPublic {
    pub fun proposeAction(action: {MyMultiSig.Action})
    pub fun executeAction(actionUUID: UInt64)
    pub fun depositVault(vault: @FungibleToken.Vault)
    pub fun depositCollection(collection: @NonFungibleToken.Collection)
    pub fun borrowManagerPublic(): &MyMultiSig.Manager{MyMultiSig.ManagerPublic}
    pub fun borrowVaultPublic(identifier: String): &FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}
    pub fun borrowCollectionPublic(identifier: String): &NonFungibleToken.Collection{NonFungibleToken.CollectionPublic}
  }

  pub resource Treasury: MyMultiSig.MultiSign, TreasuryPublic {
    pub let multiSignManager: @MyMultiSig.Manager
    access(account) var vaults: @{String: FungibleToken.Vault}
    access(account) var collections: @{String: NonFungibleToken.Collection}

    // ------- Manager -------   
    pub fun proposeAction(action: {MyMultiSig.Action}) {
      self.multiSignManager.createMultiSign(action: action)
    }

    /*
      This is arguable the most important function.
      Note that we pass through a reference to this entire
      treasury as a parameter here. So the action can do whatever it 
      wants. This means it's very imporant for the signers
      to know what they are signing. But it is also brilliant because
      we can have EVERYTHING with a multisign.

      - Want to transfer tokens? Multisign.
      - Want to deposit an NFT? Multisign.  
      - Want to allocate some tokens to X, some tokens to Y,
        do a backflip, deposit to Z? Multisign.  
      - Want to add/remove signers? Multisign.  
      - The possibilities go on.
    */
    pub fun executeAction(actionUUID: UInt64) {
      self.multiSignManager.executeAction(actionUUID: actionUUID, {"treasury": &self as &Treasury})
    }

    // Reference to Manager //
    pub fun borrowManager(): &MyMultiSig.Manager {
      return &self.multiSignManager as &MyMultiSig.Manager
    }

    pub fun borrowManagerPublic(): &MyMultiSig.Manager{MyMultiSig.ManagerPublic} {
      return &self.multiSignManager as &MyMultiSig.Manager{MyMultiSig.ManagerPublic}
    }

    // ------- Vaults ------- 

    // Deposit a Vault //
    pub fun depositVault(vault: @FungibleToken.Vault) {
      let identifier = vault.getType().identifier
      if self.vaults[identifier] != nil {
        let ref = &self.vaults[identifier] as &FungibleToken.Vault
        ref.deposit(from: <- vault)
      } else {
        self.vaults[identifier] <-! vault
      }
    }

    // Withdraw some tokens //
    pub fun withdrawTokens(identifier: String, amount: UFix64): @FungibleToken.Vault {
      let vaultRef = &self.vaults[identifier] as &FungibleToken.Vault
      return <- vaultRef.withdraw(amount: amount)
    }

    // Reference to Vault //
    pub fun borrowVault(identifier: String): &FungibleToken.Vault {
      return &self.vaults[identifier] as &FungibleToken.Vault
    }

    // Public Reference to Vault //
    pub fun borrowVaultPublic(identifier: String): &FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance} {
      return &self.vaults[identifier] as &FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}
    }


    // ------- Collections ------- 

    // Deposit a Collection //
    pub fun depositCollection(collection: @NonFungibleToken.Collection) {
      self.collections[collection.getType().identifier] <-! collection
    }

    // TODO: Figure out how to deposit individual NFTs

    // Withdraw an NFT //
    pub fun withdrawNFT(identifier: String, id: UInt64): @NonFungibleToken.NFT {
      let collectionRef = &self.collections[identifier] as &NonFungibleToken.Collection
      return <- collectionRef.withdraw(withdrawID: id)
    }

    // Reference to Collection //
    pub fun borrowCollection(identifier: String): &NonFungibleToken.Collection {
      return &self.collections[identifier] as &NonFungibleToken.Collection
    }

    // Public Reference to Collection //
    pub fun borrowCollectionPublic(identifier: String): &NonFungibleToken.Collection{NonFungibleToken.CollectionPublic} {
      return &self.collections[identifier] as &NonFungibleToken.Collection{NonFungibleToken.CollectionPublic}
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
  
  pub fun createTreasury(initialSigners: [Address]): @Treasury {
    return <- create Treasury(_initialSigners: initialSigners)
  }

  init() {
    self.TreasuryStoragePath = /storage/DAOTreasury
    self.TreasuryPublicPath = /public/DAOTreasury
  }

}